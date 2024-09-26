// MARK: - Cache Protocol

/// A protocol that defines a generic asynchronous cache.
protocol Cache {

    /// The type used as the key, which must conform to `Hashable`.
    associatedtype Key: Hashable

    /// The type of values stored in the cache.
    associatedtype Value

    /// Retrieves the value for the given key.
    /// - Parameter key: The key to look up.
    /// - Returns: The cached value, or `nil` if not found.
    func get(_ key: Key) async -> Value?

    /// Stores the value in the cache for the given key.
    /// - Parameters:
    ///   - value: The value to cache.
    ///   - key: The key for the value.
    func set(_ value: Value, for key: Key) async

    /// Removes the value for the given key.
    /// - Parameter key: The key whose value should be removed.
    func remove(_ key: Key) async

    /// Clears all entries from the cache.
    func clear() async
}

// MARK: - Cache Eviction Strategy Protocol

/// A protocol that defines the strategy for evicting items from a cache.
protocol CacheEvictionStrategy {

    /// The type used as the key, which must conform to `Hashable`.
    associatedtype Key: Hashable

    /// Tracks access for the specified key, used for eviction strategy purposes.
    /// - Parameter key: The key whose access is being tracked.
    func trackAccess(for key: Key)

    /// Determines which key should be evicted from the cache.
    /// - Returns: The key to evict, or `nil` if no key is eligible for eviction.
    func keyToEvict() -> Key?

    /// Removes the specified key from the eviction strategy tracking.
    /// - Parameter key: The key to remove.
    func removeKey(_ key: Key)

    /// Clears all keys from eviction tracking.
    func removeAll()
}
