<!--
One concern per pull request. A rename and a behaviour change in the same
diff cannot be reviewed properly or reverted cleanly.
-->

## What and why

<!-- The diff says what changed. Say why it needed to. -->

Closes #

## How it was tested

<!-- "arm64 phone, Android 14" is more useful than "works on my machine".
     The emulator behaves differently for location and notifications. -->

- [ ] `flutter test` passes
- [ ] `flutter analyze --fatal-infos` is clean
- [ ] `dart format .` produces no diff
- [ ] Tried on a physical device:

## Checklist

- [ ] Touched a Drift table or an `.arb` file → regenerated and committed
      (`dart run build_runner build --delete-conflicting-outputs`,
      `flutter gen-l10n`)
- [ ] New user-facing strings added to **both** `app_en.arb` and `app_bn.arb`
- [ ] No new network call, dependency, or Android permission — or explained
      below why one was unavoidable
- [ ] Money stays integer minor units; distance metres; volume millilitres;
      time UTC epoch millis
- [ ] Bug fix includes a regression test that fails without the fix
- [ ] Backup format change bumps `BackupFormat.currentVersion` and keeps
      older files readable
