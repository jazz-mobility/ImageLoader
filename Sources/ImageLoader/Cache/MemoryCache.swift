/// In memory `Cache` implementation using Dictionary.
final actor MemoryCache<Key: Hashable, Value, EvictionStrategy: CacheEvictionStrategy>: Cache where EvictionStrategy.Key == Key {
    private let maxSize: Int
    private var cache: [Key: Value]
    private let evictionStrategy: EvictionStrategy
    
    /// Initializes a new instance of `MemoryCache` with a specified maximum size, eviction strategy, and an optional pre-filled cache.
    /// - Parameters:
    ///   - maxSize: Maximum number of items the cache can hold before eviction occurs.
    ///   - evictionStrategy: Strategy to determine how items are removed when the cache exceeds the maximum size.
    ///   - cache: An optional dictionary that pre-fills the cache with key-value pairs. Defaults to an empty dictionary.
    init(
        maxSize: Int,
        evictionStrategy: EvictionStrategy,
        cache: [Key: Value] = [:]
    ) {
        self.maxSize = maxSize
        self.evictionStrategy = evictionStrategy
        self.cache = cache
    }
    
    func get(_ key: Key) async -> Value? {
        guard let value = cache[key] else { return nil }
        evictionStrategy.trackAccess(for: key)
        return value
    }
    
    func set(_ value: Value, for key: Key) async {
        cache[key] = value
        evictionStrategy.trackAccess(for: key)
        await purgeIfNeeded()
    }
    
    func remove(_ key: Key) async {
        cache.removeValue(forKey: key)
        evictionStrategy.removeKey(key)
    }
    
    func clear() async {
        cache.removeAll()
        evictionStrategy.removeAll()
    }
}

// MARK: - Helper functions
private extension MemoryCache {
    func purgeIfNeeded() async {
        while cache.count > maxSize, let keyToEvict = evictionStrategy.keyToEvict() {
            cache.removeValue(forKey: keyToEvict)
            evictionStrategy.removeKey(keyToEvict)
        }
    }
}
