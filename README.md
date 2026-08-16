<div align="center">

<img src="doc/store/icon-512.png" alt="Jatra" width="120">

# Jatra

**An offline-first fuel, service and ride-cost tracker for motorcycles.**

[![CI](https://github.com/firadfd/jatra/actions/workflows/ci.yml/badge.svg)](https://github.com/firadfd/jatra/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/firadfd/jatra?label=release)](https://github.com/firadfd/jatra/releases/latest)
[![Licence: GPL v3](https://img.shields.io/badge/licence-GPL--3.0-blue.svg)](LICENSE)

</div>

Log every refuel and every service. Jatra works out true mileage
(full-tank to full-tank), predicts when the next service is due, warns when
mileage drops unexpectedly, and calculates what a kilometre actually costs
once fuel, parts, servicing, insurance and depreciation are all counted.

**No account. No server. No analytics. No data leaves the device.** The app
works identically in airplane mode, and the release build requests zero
Android permissions until you switch on a feature that needs one.

## Install

Grab the latest APK from the
[releases page](https://github.com/firadfd/jatra/releases/latest).

**If you are not sure which file to take, take the `universal` one** — it
works on every phone, at ~70 MB. The per-ABI builds are a third of the size:
`arm64-v8a` suits essentially every phone sold since 2017, `armeabi-v7a`
older 32-bit devices, `x86_64` emulators. If one of those fails to install
with "app not installed", you picked the wrong architecture — use the
universal build.

Verify a download against the release's `SHA256SUMS.txt`:

```sh
sha256sum -c SHA256SUMS.txt --ignore-missing
```

Everything lives on your phone, so **uninstalling deletes your history** —
export a backup from Settings first. Upgrading over a previous release keeps
it.

## What it does

- **True mileage**, measured full-tank to full-tank rather than from a
  single fill, with partial fills folded into the window they belong to.
- **Service prediction** from your own logged intervals — engine oil, chain
  lube, brake pads, whatever you choose to track — with a local reminder
  when one comes due.
- **Real cost per kilometre**, counting fuel, parts, servicing, insurance
  and depreciation, not just what you paid at the pump.
- **A mileage-drop warning** when consumption moves against you, which is
  usually the first sign of something mechanical.
- **Optional GPS ride tracking**, off by default, drawing your route over
  OpenStreetMap. It asks for location only when you turn it on.
- **Backup and restore** to a plain, readable JSON file you own, plus CSV
  export and a raw `.sqlite` copy for same-version transfers.
- **English and Bangla**, switchable in settings.

## Privacy

The app makes exactly **one** network call: OpenStreetMap raster tiles,
fetched only while a recorded ride's map is on screen. That is the sole
reason `INTERNET` appears in the manifest. There is no crash reporter, no
analytics, no remote config and no update check.

Backups are unencrypted JSON by design — it is your data, in a format you
can read and a spreadsheet can parse. Treat an exported file the way you
would treat any other document containing your movements.

---

## Building from source

Flutter SDK on the `stable` channel; CI pins **3.47.0**.

```sh
flutter pub get
dart run build_runner build      # Drift codegen
flutter run
```

With a realistic demo dataset — one bike, 40 fuel entries over eight months,
nine services, five expenses:

```sh
flutter run --dart-define=SEED_DEMO=true
```

The seed is guarded by `kDebugMode` as well as the define, so it can never
reach a release build. It only runs when the database is empty.

## Tests

```sh
flutter test
```

## Building for release

```sh
flutter build appbundle          # what Play Store wants
flutter build apk --split-per-abi   # ~23 MB each, vs 66 MB for a fat APK
```

The fat APK carries native SQLite and geolocator binaries for every ABI;
always split, or ship a bundle. Release signing reads `android/key.properties`
if present and falls back to the debug keystore otherwise — see
[CONTRIBUTING.md](CONTRIBUTING.md#one-time-signing-setup).

Tagging `v<version>` on `main` builds and publishes signed APKs
automatically; the workflow is in
[`.github/workflows/release.yml`](.github/workflows/release.yml).

### Play Store note

`ACCESS_BACKGROUND_LOCATION` is in the manifest, which triggers a manual
review with a declaration form and a demo video. It is needed only for
"record with the screen off". Deleting that one permission line and the
`background` case from `TrackingMode` gets you back to a near-instant
review with every other feature intact.

## Layout

```
lib/
├── app/          routing, bindings, theme tokens
├── core/         calculators, formatters, shared widgets — no data-layer deps
├── data/         Drift schema, repositories, plain models
├── modules/      one folder per screen: controller + view + widgets
└── services/     settings, notifications, export/import, location
```

Repositories are plain classes that take an `AppDatabase` in their
constructor. GetX delivers them via `Get.put`, but nothing in `data/` imports
GetX or Flutter — so every one of them can be unit-tested against an
in-memory database.

See [`doc/schema_history.md`](doc/schema_history.md) for the storage
conventions, which are load-bearing: money is integer minor units, distance
is metres, volume is millilitres, time is UTC epoch millis.

## Languages

English and Bangla, switchable in settings. Prose and month names
translate; **digits stay Latin in both**. That is deliberate — see
`Fmt.numberLocale` for the three reasons, the sharpest being that the
odometer barrel splits a number by subtracting `0x30` from each code unit
and Bengali digits live at U+09E6.

Strings live in `lib/l10n/app_en.arb` and `app_bn.arb`; run
`flutter gen-l10n` after editing (a normal `flutter run` does it for you).

## Fonts

Bundled under the SIL Open Font License in `assets/fonts`, not fetched at
runtime — `google_fonts` would need network access this app does not have.

* **Barlow Condensed** — numerals, with `tnum` tabular figures so digits do
  not shift width as values change.
* **Inter** — body and UI.
* **JetBrains Mono** — units and data labels.
* **Hind Siliguri** — Bangla, wired into every style's fallback chain.

---

## Contributing

Bug reports, translations and pull requests are welcome.
**[CONTRIBUTING.md](CONTRIBUTING.md)** covers the setup and, more
importantly, the handful of rules that are load-bearing — offline-only,
integer storage units, Latin digits, and a deliberately short dependency
list. Reading it first will save you a rewrite.

Everyone taking part is expected to follow the
[Code of Conduct](CODE_OF_CONDUCT.md). Security issues go through
[SECURITY.md](SECURITY.md), not the public issue tracker.

## Licence

Copyright (C) 2026 Jatra contributors.

Jatra is free software: you can redistribute it and/or modify it under the
terms of the **GNU General Public License version 3** as published by the
Free Software Foundation. See [LICENSE](LICENSE).

It is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the licence for details.

The GPL is a deliberate choice: it means any fork you install still has to
show you its source, which is the only thing that makes "no analytics, no
server" checkable rather than a promise.

Bundled fonts are licensed separately under the SIL Open Font License; see
`assets/fonts/OFL-*.txt`. Map tiles are © OpenStreetMap contributors.
