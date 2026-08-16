# Security Policy

## Supported versions

The latest release gets fixes. Older tags do not — there is no long-term
support branch.

## Reporting a vulnerability

**Do not open a public issue.** Use GitHub's
[private vulnerability reporting](https://github.com/firadfd/jatra/security/advisories/new),
or email <firadfd833@gmail.com>.

Please include what you were doing, what happened, the app version
(Settings → About) and your Android version. A proof of concept helps.

Expect an acknowledgement within a week. If a fix is warranted it ships in
the next release, and you will be credited in the release notes unless you
would rather not be.

## Scope

Jatra stores everything on-device and makes exactly one network call —
OpenStreetMap raster tiles, only while a recorded ride's map is on screen.
The interesting attack surface is therefore local:

**In scope**

- Anything that causes data to leave the device unexpectedly.
- Backup import: `lib/services/import_service.dart` parses an
  attacker-supplied JSON file. A malformed backup should be rejected cleanly
  with nothing written, never crash into a partial import or corrupt the
  database.
- Raw `.sqlite` restore, which replaces the database wholesale.
- Anything that lets another app on the phone read Jatra's database, its
  exports, or a recorded route.
- Location data reaching anywhere other than the local database.

**Out of scope**

- Anything requiring a rooted device or physical access to an unlocked
  phone. On-device data is protected by Android's app sandbox, not by
  application-level encryption, and the app does not claim otherwise.
- OpenStreetMap's tile servers.
- Reports that boil down to "the exported backup is unencrypted" — that is
  documented behaviour. It is a plain JSON file the user chose to create and
  chose where to send.
