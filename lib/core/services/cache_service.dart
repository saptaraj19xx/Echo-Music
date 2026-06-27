/// Service for caching data in memory or on disk.
abstract class CacheService {
  /// Saves data to the cache with the given key.
  Future<void> save(String key, dynamic value);

  /// Reads data from the cache by key.
  Future<dynamic> read(String key);

  /// Removes data from the cache by key.
  Future<void> remove(String key);

  /// Clears all cached data.
  Future<void> clear();
}

/// Mock implementation of CacheService for development and testing.
///
/// Later this will be replaced with Hive or Isar for persistent storage.
class MockCacheService implements CacheService {
  final Map<String, dynamic> _cache = {};

  @override
  Future<void> save(String key, dynamic value) async {
    // Mock: save to cache
    _cache[key] = value;
  }

  @override
  Future<dynamic> read(String key) async {
    // Mock: read from cache
    return _cache[key];
  }

  @override
  Future<void> remove(String key) async {
    // Mock: remove from cache
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    // Mock: clear all cache
    _cache.clear();
  }
}