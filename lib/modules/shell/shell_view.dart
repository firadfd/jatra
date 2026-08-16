import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;

import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../fuel/fuel_history_view.dart';
import '../home/home_view.dart';
import '../map/map_view.dart';
import '../stats/stats_view.dart';
import 'shell_controller.dart';

/// The app's main frame: four destinations behind one bottom nav bar.
///
/// Each tab keeps its own `Scaffold` — and with it its own app bar and FAB —
/// inside an [IndexedStack], so switching tabs preserves scroll position and
/// in-flight state instead of rebuilding the screen from scratch. That matters
/// most for the map tab, which would otherwise re-fit its camera every time
/// the user came back to it.
///
/// Screens that are not destinations (service, expenses, the forms, settings)
/// are still pushed over this frame as full routes, which is what hides the
/// nav bar while a form is open — correct, since a half-filled form should not
/// offer four ways to abandon itself.
class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.jatra;
    final l = L.of(context);

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.index,
          children: const [
            HomeView(),
            FuelHistoryView(),
            MapView(),
            StatsView(),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        // The same hairline that separates every other surface in the app,
        // standing in for the elevation this theme does not use.
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: c.border, width: Dimens.border),
          ),
        ),
        child: Obx(
          () => NavigationBar(
            selectedIndex: controller.index,
            onDestinationSelected: controller.goToIndex,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.speed_outlined),
                selectedIcon: const Icon(Icons.speed),
                label: l.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.local_gas_station_outlined),
                selectedIcon: const Icon(Icons.local_gas_station),
                label: l.navFuel,
              ),
              NavigationDestination(
                icon: const Icon(Icons.map_outlined),
                selectedIcon: const Icon(Icons.map),
                label: l.navMap,
              ),
              NavigationDestination(
                icon: const Icon(Icons.insights_outlined),
                selectedIcon: const Icon(Icons.insights),
                label: l.navStats,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
