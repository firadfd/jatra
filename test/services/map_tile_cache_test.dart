// The map used to go blank the moment the phone lost signal, even over
// ground the rider had looked at a dozen times.
//
// flutter_map does cache tiles, but only serves them without a network call
// while they are *fresh*. A stale tile is revalidated against the server
// first, and when that request fails with no connection flutter_map paints a
// transparent square rather than falling back to the perfectly good bytes on
// disk. OSM's Cache-Control is a few days, so anything looked at last week
// was blank today.
//
// `OfflineFirstTileCache` closes exactly that gap, and does it by changing one
// thing only: the answer to "is this tile stale?" while offline.
import 'dart:typed_data';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jatra/services/map_tile_cache.dart';

/// An in-memory stand-in for flutter_map's on-disk cache.
class _FakeStore implements MapCachingProvider {
  _FakeStore(this.tile);

  CachedMapTile? tile;
  int putCount = 0;

  @override
  bool get isSupported => true;

  @override
  Future<CachedMapTile?> getTile(String url) async => tile;

  @override
  Future<void> putTile({
    required String url,
    required CachedMapTileMetadata metadata,
    Uint8List? bytes,
  }) async => putCount++;
}

void main() {
  final bytes = Uint8List.fromList([137, 80, 78, 71]); // PNG magic number

  /// A tile that went stale an hour ago — the ordinary state of anything
  /// cached more than a few days back.
  CachedMapTile staleTile() => (
    bytes: bytes,
    metadata: CachedMapTileMetadata(
      staleAt: DateTime.timestamp().subtract(const Duration(hours: 1)),
      lastModified: DateTime.utc(2026, 8, 1),
      etag: '"abc123"',
    ),
  );

  test('offline, a stale tile is served instead of a blank square', () async {
    final store = _FakeStore(staleTile());
    final cache = OfflineFirstTileCache(store, () => false);

    final tile = await cache.getTile('https://tile.example/1/2/3.png');

    expect(tile, isNotNull);
    expect(
      tile!.metadata.isStale,
      isFalse,
      reason:
          'reported fresh so flutter_map returns it directly; the alternative '
          'on offer offline is not a newer tile, it is no tile',
    );
    expect(tile.bytes, same(bytes), reason: 'the image itself is untouched');
  });

  test('offline, the revalidation headers survive for later', () async {
    final store = _FakeStore(staleTile());
    final cache = OfflineFirstTileCache(store, () => false);

    final tile = await cache.getTile('https://tile.example/1/2/3.png');

    // Dropping these would cost a full tile download per tile on the next
    // revalidation, where the server could have answered 304.
    expect(tile!.metadata.etag, '"abc123"');
    expect(tile.metadata.lastModified, DateTime.utc(2026, 8, 1));
  });

  test('online, a stale tile stays stale and is revalidated', () async {
    final store = _FakeStore(staleTile());
    final cache = OfflineFirstTileCache(store, () => true);

    final tile = await cache.getTile('https://tile.example/1/2/3.png');

    expect(
      tile!.metadata.isStale,
      isTrue,
      reason:
          'with a connection available the map must still pick up map changes '
          '— the override is a fallback, not a freeze',
    );
  });

  test('connectivity is re-read per tile, not captured once', () async {
    var online = true;
    final store = _FakeStore(staleTile());
    final cache = OfflineFirstTileCache(store, () => online);

    expect((await cache.getTile('u'))!.metadata.isStale, isTrue);

    // Riding out of coverage mid-map, which is the whole point.
    online = false;
    expect((await cache.getTile('u'))!.metadata.isStale, isFalse);
  });

  test('a tile that was never cached stays a miss in both states', () async {
    final store = _FakeStore(null);

    expect(await OfflineFirstTileCache(store, () => true).getTile('u'), isNull);
    expect(
      await OfflineFirstTileCache(store, () => false).getTile('u'),
      isNull,
    );
  });

  test('writes pass straight through to the real store', () async {
    final store = _FakeStore(null);
    final cache = OfflineFirstTileCache(store, () => true);

    await cache.putTile(
      url: 'u',
      metadata: CachedMapTileMetadata(
        staleAt: DateTime.timestamp(),
        lastModified: null,
        etag: null,
      ),
      bytes: bytes,
    );

    expect(store.putCount, 1);
  });
}
