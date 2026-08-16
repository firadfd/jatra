# Schema history

One row per released schema version. Adding a column means:

1. Change the table in `lib/data/db/tables/tables.dart`.
2. Bump `schemaVersion` in `lib/data/db/database.dart`.
3. Append an `if (from < N)` block to `_upgrade` — never edit an existing one,
   because a device jumping v1 → v4 runs every intervening block in order.
4. Add a row here.
5. Re-run `dart run build_runner build`.

A JSON backup carries its own `schemaVersion`. The importer refuses a file
newer than the app can read, and migrates older ones on the way in.

| Version | Released | Change |
|---------|----------|--------|
| 1 | unreleased | Initial schema: `vehicles`, `fuel_entries`, `service_items`, `service_logs`, `expenses`, `rides`, `ride_points`, `reminders`. |

## Backup format

`BackupFormat.currentVersion` in `lib/data/models/backup.dart` is versioned
**separately** from the database `schemaVersion` above, and deliberately so:
the JSON is a published format that other tools may read, and it should not
churn every time an internal column is renamed.

The importer refuses a file newer than it can read, and names the reason.
Serialisers are written by hand for the same reason — a field name in the JSON
must not move because a Dart class was refactored.

| Backup version | Released | Change |
|----------------|----------|--------|
| 1 | unreleased | Initial format. |

## Storage conventions

These are load-bearing. Nothing in the database is a floating-point number
except GPS coordinates, speed and accuracy, where precision loss is
meaningless and exactness is not achievable anyway.

| Quantity | Column suffix | Unit |
|----------|---------------|------|
| distance | `…M` | metres |
| volume | `…Ml` | millilitres |
| money | `…Minor` | currency minor units (paisa, cents) |
| time | `…Ms` | UTC epoch milliseconds |

A vehicle's `distanceUnit` / `volumeUnit` / `currency` affect display and
input parsing only. Changing them never rewrites a row.

## Soft deletes

Every table except `ride_points` carries a nullable `deletedAt`. Ordinary
deletes tombstone the row so a later JSON import can distinguish "the user
deleted this" from "this device never had it". Only *Delete all data* and a
Replace-all import hard-delete.

`ride_points` is exempt: it hangs off `rides`, which is itself tombstoned, and
writing 41,000 tombstones to hide one ride is pure cost.
