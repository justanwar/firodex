import 'dart:async';

import 'package:komodo_defi_sdk/komodo_defi_sdk.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:web_dex/shared/constants.dart';

/// Caches activated assets to avoid repeated RPC calls.
class ActivatedAssetsCache {
  ActivatedAssetsCache._(this._sdk)
    : _cacheDuration = kActivationPollingInterval;

  static final Expando<ActivatedAssetsCache> _expando =
      Expando<ActivatedAssetsCache>('ActivatedAssetsCache');

  final KomodoDefiSdk _sdk;

  Duration _cacheDuration;
  List<Asset>? _cachedAssets;
  DateTime? _lastFetchedAt;
  Future<List<Asset>>? _pendingFetch;

  /// Returns a cache instance associated with the provided SDK.
  static ActivatedAssetsCache of(KomodoDefiSdk sdk) {
    return _expando[sdk] ??= ActivatedAssetsCache._(sdk);
  }

  /// Updates the cache duration. Values less than or equal to zero disable caching.
  void updateCacheDuration(Duration duration) {
    if (duration <= Duration.zero) {
      _cacheDuration = Duration.zero;
      invalidate();
      return;
    }
    _cacheDuration = duration;
  }

  /// Returns the list of activated assets, using a cached value when available.
  Future<List<Asset>> getActivatedAssets({bool forceRefresh = false}) async {
    if (forceRefresh) {
      invalidate();
    }

    if (_hasValidCache) {
      return _cachedAssets!;
    }

    final pending = _pendingFetch;
    if (pending != null) {
      return pending;
    }

    final future = _sdk.assets.getActivatedAssets();
    _pendingFetch = future;
    try {
      final assets = await future;
      _cachedAssets = assets;
      _lastFetchedAt = DateTime.now();
      return assets;
    } finally {
      if (identical(_pendingFetch, future)) {
        _pendingFetch = null;
      }
    }
  }

  /// Returns the set of activated asset IDs.
  Future<Set<AssetId>> getActivatedAssetIds({bool forceRefresh = false}) async {
    final assets = await getActivatedAssets(forceRefresh: forceRefresh);
    return assets.map((asset) => asset.id).toSet();
  }

  /// Invalidates the current cache forcing the next call to fetch fresh data.
  void invalidate() {
    _cachedAssets = null;
    _lastFetchedAt = null;
    _pendingFetch = null;
  }

  bool get _hasValidCache {
    if (_cachedAssets == null || _lastFetchedAt == null) {
      return false;
    }
    if (_cacheDuration == Duration.zero) {
      return false;
    }
    final elapsed = DateTime.now().difference(_lastFetchedAt!);
    return elapsed <= _cacheDuration;
  }
}
