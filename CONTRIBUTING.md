# Contributing to Jatra

Thanks for wanting to help. Jatra is a small app with a few strong opinions,
and most of this document is about those opinions — not because process
matters here, but because a change that violates one of them is expensive to
unwind after it ships to someone's phone.

By contributing you agree that your work is licensed under the
[GNU GPL v3](LICENSE), the same as the rest of the project.

Everyone taking part is expected to follow the
[Code of Conduct](CODE_OF_CONDUCT.md).

---

## Getting set up

You need the Flutter SDK on the `stable` channel. CI pins **3.47.0**; matching
it locally avoids surprises.

```sh
git clone https://github.com/firadfd/jatra.git
cd jatra
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter run
```

Work against realistic data rather than an empty database — one bike, 40 fuel
entries over eight months, nine services, five expenses:

```sh
flutter run --dart-define=SEED_DEMO=true
```

The seed is guarded by `kDebugMode` *and* the define, so it cannot reach a
release build, and it only runs when the database is empty.

## Before you open a pull request

These four are exactly what CI runs. Running them locally saves a round trip:

```sh
dart format .
flutter analyze --fatal-infos
dart run build_runner build --delete-conflicting-outputs
flutter test
```

Generated code — `lib/data/db/database.g.dart` and `lib/l10n/app_localizations*.dart`
— **is committed**. If you touch a Drift table or an `.arb` file, regenerate
and commit the result in the same change. CI regenerates and fails on any
diff, because a stale checkout compiles against yesterday's schema.

---

## The rules that are load-bearing

### 1. Nothing leaves the device

The whole premise is "no account, no server, no analytics, works in airplane
mode". The app makes exactly **one** network call: OpenStreetMap raster tiles
behind a recorded ride, which is why `INTERNET` is in the manifest.

A change that adds a second one will be declined. That includes crash
reporters, analytics, remote config, font fetching, update checks and
"anonymous" telemetry. There is no threshold of usefulness that buys an
exception, because the promise is only worth anything if it is absolute.

### 2. Storage units are fixed and integer

Documented in [`doc/schema_history.md`](doc/schema_history.md), and violating
them silently corrupts arithmetic rather than failing loudly:

| Quantity | Stored as |
|---|---|
| Money | integer **minor units** (paisa) — never a `double` |
| Distance | integer **metres** |
| Volume | integer **millilitres** |
| Time | integer **UTC epoch milliseconds** |

Floating-point money is the specific thing being avoided. Conversion to
display units happens at the edge, in `core/utils`, never in the database.

### 3. `data/` imports neither GetX nor Flutter

Repositories are plain classes taking an `AppDatabase` in the constructor.
GetX delivers them via `Get.put`, but nothing under `lib/data/` may import
`get` or `package:flutter`. That constraint is what lets every repository be
unit-tested against an in-memory database, and the tests under `test/data/`
depend on it holding.

### 4. Digits stay Latin in both languages

Prose and month names translate to Bangla; **numerals do not**. This is
deliberate and there are three reasons in `Fmt.numberLocale`. The sharpest:
the odometer barrel widget splits a number by subtracting `0x30` from each
code unit, and Bengali digits live at U+09E6.

Add strings to `lib/l10n/app_en.arb` and `lib/l10n/app_bn.arb`, then run
`flutter gen-l10n` (a normal `flutter run` does it for you). Never hardcode
user-facing English in a widget.

### 5. New permissions are a big deal

The release build requests **zero** Android permissions until the user turns
on a feature that needs one. `ACCESS_BACKGROUND_LOCATION` already costs a
manual Play Store review with a declaration form and a demo video.

Adding a permission needs a strong argument in the pull request describing
what breaks without it and why an existing capability will not do.

### 6. Dependencies are argued for, not added

Every entry in `pubspec.yaml` has a comment explaining why it is there — and
several explain why a popular alternative is *not*: `permission_handler`,
`flutter_foreground_task` and `google_fonts` are each deliberately absent for
reasons written down in the file. Read those before proposing an addition.

Two pairs are version-locked and will break subtly if bumped alone:

- **`share_plus` / `file_picker`** — `share_plus` 13 wants `win32` ^6 while
  `file_picker` <12 wants `win32` ^5. Pub resolves the standoff by silently
  dropping `file_picker` to 3.0.4, a 2021 release that does not work on a
  modern Android. Pinning `share_plus` to 10.x keeps `file_picker` on 10.x.
- **`intl`** — pinned to the exact version `flutter_localizations` depends
  on. A caret range resolves higher and the two then refuse to coexist.

### 7. The backup format is a compatibility surface

`lib/data/models/backup.dart` defines a JSON format that users have files
in. Rules:

- Adding a field is fine. Renaming or removing one is a schema-version bump.
- `BackupFormat.magic` is `jatra-backup`. `legacyMagic` (`odo-backup`,
  from before the app was renamed) stays accepted on import forever — those
  files exist on people's phones.
- Bump `currentVersion` when the written shape changes, and only raise
  `minimumSupportedVersion` when you genuinely cannot read the old one.
- Round-trip tests in `test/data/backup_test.dart` are not optional.

---

## Tests

`flutter test` must pass. Beyond that:

- **Calculation changes need a test.** Mileage, cost-per-km, service
  prediction and money arithmetic are the reason people trust the app.
  `test/core/` is the place.
- **Repository changes** get tested against an in-memory database, not a
  mock — see any file in `test/data/`.
- **Bug fixes get a regression test** that fails before your fix.
  `test/widget/red_box_regression_test.dart` is the model: it names the
  original defect in a comment at the top.

## Pull requests

- One concern per pull request. A rename and a behaviour change in the same
  diff cannot be reviewed properly or reverted cleanly.
- Explain **why**, not what — the diff already says what.
- Say what you tested on. "arm64 phone, Android 14" is useful; the emulator
  behaves differently for location and notifications in particular.
- Match the surrounding code. This codebase comments the *reasoning* behind
  non-obvious decisions and skips comments that restate the line below.
  Follow that.
- Draft PRs are welcome for early feedback.

## Reporting bugs

Open an issue with the app version (Settings → About), your Android version
and device, and what you did. If it involves your data, **do not attach a
backup file** — it contains your full history. Describe the shape of the
problem instead, or redact.

---

## Cutting a release

Maintainers only.

1. Bump `version:` in `pubspec.yaml` (`versionName+versionCode`). Keep it in
   sync with the `appVersion` written into JSON backups.
2. Commit to `main`.
3. Tag and push:

   ```sh
   git tag v1.2.0
   git push origin v1.2.0
   ```

`.github/workflows/release.yml` then verifies the tag is an ancestor of
`main` and matches `pubspec.yaml`, runs the test suite, builds signed
per-ABI APKs plus the app bundle, and publishes a GitHub Release with
`SHA256SUMS.txt`.

### One-time signing setup

The workflow fails immediately if these are missing, rather than publishing
a debug-signed APK that can never be upgraded over.

Generate an upload keystore — **back it up somewhere safe and never commit
it**. Losing it means no existing install can ever be upgraded:

```sh
keytool -genkey -v -keystore jatra-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias jatra
base64 -i jatra-release.jks | pbcopy    # Linux: base64 -w0 jatra-release.jks
```

Then add four repository secrets under **Settings → Secrets and variables →
Actions**:

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | the base64 blob from above |
| `KEYSTORE_PASSWORD` | keystore password |
| `KEY_ALIAS` | `jatra` |
| `KEY_PASSWORD` | key password |

For local release builds, copy the template instead — the copy is
git-ignored:

```sh
cp android/key.properties.example android/key.properties
```

```properties
storeFile=jatra-release.jks
storePassword=...
keyAlias=jatra
keyPassword=...
```

Fill in real values. A `key.properties` left holding the template's
`CHANGEME` placeholders is worse than no file at all: its presence switches
the build onto the release signing path, which then fails on the wrong
password rather than falling back to debug.

Without that file the release build falls back to the debug keystore so
`flutter run --release` still works. That output is fine for testing and
useless for distribution.
