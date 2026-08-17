// Ride recording used to have three modes, and the middle one — `appOpen` —
// stopped the moment the app left the screen. That is gone: a ride now runs
// from Start to Finish behind a foreground service, so the only question left
// is on or off.
//
// What is checked here is the upgrade path. Settings are persisted by *name*,
// so an install that was sitting on `appOpen` still has that string in its
// box after the update, and `TrackingMode.values.byName` would throw on it
// partway through `SettingsService.init()` — taking the launch down with it.
import 'package:flutter_test/flutter_test.dart';

import 'package:jatra/data/models/enums.dart';
import 'package:jatra/services/settings_service.dart';

void main() {
  group('stored tracking mode', () {
    test('a fresh install has tracking off', () {
      expect(
        SettingsService.trackingModeFromStored(null),
        TrackingMode.off,
        reason: 'the app must be usable without ever granting location',
      );
    });

    test('the retired appOpen mode upgrades to on, not off', () {
      expect(
        SettingsService.trackingModeFromStored('appOpen'),
        TrackingMode.background,
        reason:
            'someone on appOpen had chosen to record rides; dropping them to '
            'off on upgrade would silently stop recording anything',
      );
    });

    test('the surviving names round-trip', () {
      for (final mode in TrackingMode.values) {
        expect(SettingsService.trackingModeFromStored(mode.name), mode);
      }
    });

    test('an unrecognised name falls back to off rather than throwing', () {
      // A downgrade, a corrupted box, or a value from a future build. None of
      // those is worth crashing a launch over, and off is the safe answer
      // because it touches no hardware.
      expect(
        SettingsService.trackingModeFromStored('whoKnows'),
        TrackingMode.off,
      );
    });
  });

  test('there is no foreground-only mode left to select', () {
    expect(TrackingMode.values.map((m) => m.name), ['off', 'background']);
  });
}
