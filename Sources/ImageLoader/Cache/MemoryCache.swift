import Foundation

/// In memory `Cache` implementation using Dictionary.
final actor MemoryCache: Cache {
    private let maxSize: Int
    private var cache: [AnyHashable: Data]
    private let evictionStrategy: CacheEvictionStrategy

    /// Initializes a new instance of `MemoryCache` with a specified maximum size, eviction strategy, and an optional pre-filled cache.
    /// - Parameters:
    ///   - maxSize: Maximum number of items the cache can hold before eviction occurs.
    ///   - evictionStrategy: Strategy to determine how items are removed when the cache exceeds the maximum size.
    ///   - cache: An optional dictionary that pre-fills the cache with key-value pairs. Defaults to an empty dictionary.
    init(
        maxSize: Int,
        evictionStrategy: CacheEvictionStrategy,
        cache: [AnyHashable: Data] = [:]
    ) {
        self.maxSize = maxSize
        self.evictionStrategy = evictionStrategy
        self.cache = cache
    }
    
    public func get(_ key: AnyHashable) async -> Data? {
        guard let value = cache[key] else { return nil }
        evictionStrategy.trackAccess(for: key)
        return value
    }
    
    public func set(_ value: Data, for key: AnyHashable) async {
        cache[key] = value
        evictionStrategy.trackAccess(for: key)
        await purgeIfNeeded()
    }
    
    public func remove(_ key: AnyHashable) async {
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
