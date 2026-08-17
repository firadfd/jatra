import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart' hide Value;
import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps map tiles readable with the radio off.
///
/// flutter_map already caches tiles to disk. Two things stopped that from
/// surviving a trip out of signal, and this service fixes both:
///
/// 1. **Where.** The built-in cache defaults to the platform cache directory —
///    on Android, the one the OS is free to empty under storage pressure and
///    the one "Clear cache" wipes. Tiles are pointed at the app support
///    directory instead, which persists until the user clears the app's
///    storage outright.
/// 2. **When.** A *fresh* cached tile is served without a network call, but a
///    *stale* one is revalidated against the server first — and when that
///    request fails with no connection, flutter_map returns a transparent tile
///    rather than the perfectly good bytes already sitting on disk. That is
///    the blank map. [_OfflineFirstTileCache] closes it.
///
/// Nothing here downloads a tile that was not going to be fetched anyway.
/// OpenStreetMap's tile usage policy forbids bulk downloading, and asks that
/// tiles not be requested unnecessarily — so this only keeps what the map has
/// already drawn, and the long freshness window below means it asks OSM for it
/// *less* often than before, not more.
class MapTileCache extends GetxService {
  /// Tiles live under the app support directory, not the cache directory.
  static const _directoryName = 'map_tiles';

  /// Roughly 13,000 tiles at OSM's typical ~15 KB each — several cities' worth
  /// of streets. flutter_map's own default is 1 GB, which is more than this
  /// app has any business claiming on a phone.
  static const _maxCacheBytes = 200 * 1024 * 1024;

  /// How long a tile is treated as current before it is revalidated.
  ///
  /// Deliberately far longer than the few days OSM's `Cache-Control` asks for.
  /// Street geometry does not change weekly, a stale tile is a vastly better
  /// answer than a blank one, and every revalidation skipped is one fewer
  /// request to a volunteer-funded tile server.
  static const _freshFor = Duration(days: 30);

  /// The HTTP client every tile request goes through, wrapped so that the
  /// success or failure of those requests is itself the connectivity signal.
  /// One retry rather than flutter_map's three: offline, the retries only
  /// delay the fall back to cache.
  final _client = _ReachabilityClient(RetryClient(Client(), retries: 1));

  BuiltInMapCachingProvider? _store;
  Directory? _directory;

  /// The tile provider to hand to a `TileLayer`, or null before [init] has
  /// run — in which case flutter_map's own default applies and tiles simply
  /// are not offline-backed.
  MapCachingProvider? _caching;

  Future<MapTileCache> init() async {
    try {
      final base = await getApplicationSupportDirectory();
      final directory = Directory('${base.path}/$_directoryName');
      _directory = directory;

      // `getOrCreateInstance` is a singleton whose configuration is honoured
      // only on first creation, and flutter_map creates a default one on the
      // first tile it draws. This therefore has to run before any map is
      // built — see `main()`.
      _store = BuiltInMapCachingProvider.getOrCreateInstance(
        cacheDirectory: directory.path,
        maxCacheSize: _maxCacheBytes,
        overrideFreshAge: _freshFor,
      );
      _caching = OfflineFirstTileCache(_store!, () => _client.online);
    } on Object {
      // A device that will not give us a directory still gets a working map,
      // just not an offline one. Not worth failing a launch over.
      _caching = null;
    }
    return this;
  }

  /// A tile provider backed by the offline-first cache.
  ///
  /// Returns flutter_map's default when this service was never registered or
  /// its directory could not be opened — which is the case in widget tests and
  /// previews, where a plain network provider is exactly what is wanted.
  static TileProvider? providerOrNull() {
    if (!Get.isRegistered<MapTileCache>()) return null;
    final caching = Get.find<MapTileCache>()._caching;
    if (caching == null) return null;

    // A fresh provider per layer, sharing the one client and one cache. The
    // provider is cheap; the client and the cache are what must be shared.
    return NetworkTileProvider(
      cachingProvider: caching,
      httpClient: Get.find<MapTileCache>()._client,
    );
  }

  /// Bytes currently held on disk, for the settings screen to report.
  ///
  /// Walked rather than tracked: flutter_map keeps its own size ledger for the
  /// reducer, but does not expose it, and a directory walk of a few thousand
  /// files is fast enough for a screen the user opens by hand.
  Future<int> sizeBytes() async {
    final directory = _directory;
    if (directory == null) return 0;

    try {
      if (!directory.existsSync()) return 0;
      var total = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) total += await entity.length();
      }
      return total;
    } on Object {
      return 0;
    }
  }

  /// Deletes every cached tile, then reopens the cache so the map keeps
  /// working without a restart.
  Future<void> clear() async {
    final store = _store;
    if (store == null) return;

    try {
      await store.destroy(deleteCache: true);
    } on Object {
      // Fall through and reopen regardless — a half-deleted cache that still
      // works beats a working cache the user cannot clear.
    }
    _store = null;
    _caching = null;
    await init();
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}

/// Serves cached tiles regardless of age while the network is unreachable.
///
/// The only thing this changes is the answer to "is this tile stale?". Online,
/// tiles pass through untouched and revalidate on flutter_map's usual terms.
/// Offline, a cached tile is reported as fresh, which is what makes
/// flutter_map return it instead of attempting a request that cannot succeed
/// and painting a transparent square when it fails.
///
/// Reporting a tile as fresh is honest here in the way that matters: the
/// alternative on offer is not a newer tile, it is no tile.
@visibleForTesting
class OfflineFirstTileCache implements MapCachingProvider {
  const OfflineFirstTileCache(this._inner, this._isOnline);

  final MapCachingProvider _inner;

  /// Read on every tile, not captured once — connectivity is exactly the
  /// thing that changes underneath you mid-ride.
  final bool Function() _isOnline;

  /// Long enough that the tile is served, short enough that it means nothing
  /// beyond "not now" — the override is recomputed on every read, and stops
  /// applying the moment a request succeeds again.
  static const _offlineGrace = Duration(days: 365);

  @override
  bool get isSupported => _inner.isSupported;

  @override
  Future<CachedMapTile?> getTile(String url) async {
    final tile = await _inner.getTile(url);
    if (tile == null || _isOnline()) return tile;

    return (
      bytes: tile.bytes,
      metadata: CachedMapTileMetadata(
        staleAt: DateTime.timestamp().add(_offlineGrace),
        // Carried through unchanged, so that the moment the network is back
        // the next revalidation still sends If-None-Match / If-Modified-Since
        // and the server can answer 304 instead of resending the tile.
        lastModified: tile.metadata.lastModified,
        etag: tile.metadata.etag,
      ),
    );
  }

  @override
  Future<void> putTile({
    required String url,
    required CachedMapTileMetadata metadata,
    Uint8List? bytes,
  }) => _inner.putTile(url: url, metadata: metadata, bytes: bytes);
}

/// An HTTP client that remembers whether the last tile request got through.
///
/// This is the connectivity check, and it costs nothing: the app is already
/// making these requests, so their outcome is a more accurate signal of "can
/// we reach the tile server" than any connectivity plugin — which reports the
/// state of the radio, not whether anything is actually reachable through it.
class _ReachabilityClient extends BaseClient {
  _ReachabilityClient(this._inner);

  final Client _inner;

  /// Optimistic at launch. The first failed tile flips it, and from then on
  /// every cached tile is served straight from disk.
  bool online = true;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    try {
      final response = await _inner.send(request);
      online = true;
      return response;
    } on ClientException {
      online = false;
      rethrow;
    } on SocketException {
      online = false;
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
