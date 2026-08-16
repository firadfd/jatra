import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_colors.dart';
import '../../data/db/database.dart';
import '../../data/repositories/expense_repo.dart';
import '../../data/repositories/fuel_repo.dart';
import '../../data/repositories/service_repo.dart';
import '../../l10n/app_localizations.dart';
import '../../modules/vehicles/vehicle_controller.dart';
import '../settings_service.dart';
import 'offscreen_renderer.dart';
import 'widget_face.dart';
import 'widget_shapes.dart';
import 'widget_snapshot.dart';

/// Keeps the Android home-screen widget in step with the log.
///
/// The widget shows **all-time** figures, which can only change while the app
/// is running — there is no server, and nothing logs a refuel but the user.
/// So there is no background isolate here and no periodic wake-up: the app
/// redraws when the data changes and when it goes to the background, and
/// Android redraws from what it already has for as long as the app stays
/// closed.
///
/// One bitmap per shape rather than one per placed widget, so a resize on
/// the home screen can be answered from disk instead of waiting for the app
/// to be opened again. See [WidgetPanel] for why.
///
/// Every path is a no-op off Android, and only the panels the user has
/// actually put on a home screen are drawn — [_placedPanels] usually comes
/// back with one or two of the five, and an empty list costs nothing at
/// all.
class HomeWidgetService extends GetxService with WidgetsBindingObserver {
  HomeWidgetService(
    this._db,
    this._vehicles,
    this._settings,
    FuelRepo fuel,
    ServiceRepo service,
    ExpenseRepo expenses,
  ) : _builder = WidgetSnapshotBuilder(fuel, service, expenses);

  static const _channel = MethodChannel('com.firad.jatra/home_widget');

  /// Writes to the log arrive in bursts — a fuel entry updates its row and
  /// the service item's baseline in one transaction — and a resize can fire
  /// several times as the user drags. One redraw at the end of the burst is
  /// enough.
  static const _debounce = Duration(milliseconds: 700);

  /// Drawn at 3x so the face stays crisp when Android scales it up to a
  /// widget larger than the shape's nominal size. PNG keeps each one to a
  /// few tens of kilobytes.
  static const _pixelRatio = 3.0;

  final AppDatabase _db;
  final VehicleController _vehicles;
  final SettingsService _settings;
  final WidgetSnapshotBuilder _builder;

  final _subscriptions = <StreamSubscription<void>>[];
  final _workers = <Worker>[];
  Timer? _pending;

  /// Guards against two refreshes overlapping — a data change landing while
  /// a render is in flight schedules another rather than interleaving.
  bool _rendering = false;
  bool _dirty = false;

  /// Set once the app starts heading for the background, cleared on resume,
  /// so one departure is one redraw.
  bool _leaving = false;

  bool get _supported => !kIsWeb && Platform.isAndroid;

  Future<HomeWidgetService> init() async {
    if (!_supported) return this;

    WidgetsBinding.instance.addObserver(this);

    // Any write to a table the widget reads. Rides and reminders are
    // deliberately absent: neither appears on the widget, and a live ride
    // writes a GPS point every second or so.
    _subscriptions.add(
      _db
          .tableUpdates(
            TableUpdateQuery.onAllTables([
              _db.vehicles,
              _db.fuelEntries,
              _db.serviceLogs,
              _db.expenses,
            ]),
          )
          .listen((_) => schedule()),
    );

    _workers.addAll([
      ever(_vehicles.active, (_) => schedule()),
      ever(_settings.themeMode, (_) => schedule()),
      ever(_settings.localeCode, (_) => schedule()),
    ]);

    schedule();
    return this;
  }

  @override
  void onClose() {
    if (_supported) WidgetsBinding.instance.removeObserver(this);
    _pending?.cancel();
    for (final s in _subscriptions) {
      s.cancel();
    }
    for (final w in _workers) {
      w.dispose();
    }
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Leaving the app is the one moment the widget is about to be looked at,
    // and the only moment a resize that happened while we were closed can be
    // answered at the right size.
    //
    // `inactive` rather than `paused`: it arrives first and while the engine
    // is certainly still able to rasterise. Going to the background delivers
    // both, so [_leaving] collapses them into a single redraw.
    switch (state) {
      case AppLifecycleState.resumed:
        _leaving = false;
      case AppLifecycleState.inactive || AppLifecycleState.paused:
        if (_leaving) return;
        _leaving = true;
        refresh();
      case _:
        break;
    }
  }

  /// Coalesces a burst of changes into one redraw.
  void schedule() {
    if (!_supported) return;
    _pending?.cancel();
    _pending = Timer(_debounce, refresh);
  }

  /// Recomputes and redraws every placed widget.
  ///
  /// Failures are swallowed with a debug log: a home-screen widget that
  /// cannot be drawn is a cosmetic problem, and it must never take a screen
  /// the user is actually looking at down with it.
  Future<void> refresh() async {
    if (!_supported) return;

    if (_rendering) {
      _dirty = true;
      return;
    }
    _rendering = true;

    try {
      final panels = await _placedPanels();
      if (panels.isEmpty) return;

      final snapshot = await _builder.build(
        vehicle: _vehicles.active.value,
        fmt: _vehicles.fmt.value,
        mileageDropThreshold: _settings.mileageDropThreshold.value,
        defaultDepreciationPercent: _settings.defaultDepreciationPercent.value,
      );

      final colors = _colors();
      final l10n = await L.delegate.load(_settings.locale);

      for (final panel in panels) {
        for (var i = 0; i < panel.shapes.length; i++) {
          final shape = panel.shapes[i];
          final png = await OffscreenRenderer.toPng(
            size: shape,
            pixelRatio: _pixelRatio,
            child: WidgetFace(
              panel: panel,
              snapshot: snapshot,
              colors: colors,
              l10n: l10n,
              size: shape,
            ),
          );
          if (png == null) continue;

          // The aspect travels with the bitmap so Android can match a
          // resized widget against it without a second copy of this table.
          await _channel.invokeMethod<void>('update', {
            'panel': panel.name,
            'shape': '$i',
            'aspect': WidgetPanel.aspectOf(shape),
            'png': png,
          });
        }
      }

      // Once, after the whole set has landed. Redrawing per shape would
      // walk every widget visibly through four wrong proportions first.
      await _channel.invokeMethod<void>('redraw');
    } catch (error, stack) {
      debugPrint('Home-screen widget refresh failed: $error\n$stack');
    } finally {
      _rendering = false;
      if (_dirty) {
        _dirty = false;
        schedule();
      }
    }
  }

  /// Which of the five widgets are on a home screen right now.
  ///
  /// Asked every refresh rather than assumed, because rendering five shapes
  /// of a chart nobody has placed is exactly the kind of work a battery
  /// notices. An unknown name from an older install is ignored rather than
  /// throwing.
  Future<List<WidgetPanel>> _placedPanels() async {
    final names = await _channel.invokeListMethod<String>('placedPanels');
    if (names == null) return const [];

    return [
      for (final panel in WidgetPanel.values)
        if (names.contains(panel.name)) panel,
    ];
  }

  /// The widget follows the app's own theme setting rather than the
  /// launcher's, because that is the theme the user chose for Jatra and the
  /// one every other Jatra surface is wearing.
  JatraColors _colors() {
    final isDark = switch (_settings.themeMode.value) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
    };
    return isDark ? JatraColors.dark : JatraColors.light;
  }
}
