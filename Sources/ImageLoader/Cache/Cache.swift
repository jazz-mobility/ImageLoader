import Foundation

// MARK: - Cache Protocol

/// A protocol that defines a generic asynchronous cache.
public protocol Cache {
    /// Retrieves the value for the given key.
    /// - Parameter key: The key to look up.
    /// - Returns: The cached value, or `nil` if not found.
    func get(_ key: AnyHashable) async -> Data?

    /// Stores the value in the cache for the given key.
    /// - Parameters:
    ///   - value: The value to cache.
    ///   - key: The key for the value.
    func set(_ value: Data, for key: AnyHashable) async

    /// Removes the value for the given key.
    /// - Parameter key: The key whose value should be removed.
    func remove(_ key: AnyHashable) async

    /// Clears all entries from the cache.
    func clear() async
}

// MARK: - Cache Eviction Strategy Protocol

/// A protocol that defines the strategy for evicting items from a cache.
protocol CacheEvictionStrategy {

    /// Tracks access for the specified key, used for eviction strategy purposes.
    /// - Parameter key: The key whose access is being tracked.
    func trackAccess(for key: AnyHashable)

    /// Determines which key should be evicted from the cache.
    /// - Returns: The key to evict, or `nil` if no key is eligible for eviction.
    func keyToEvict() -> (AnyHashable)?

    /// Removes the specified key from the eviction strategy tracking.
    /// - Parameter key: The key to remove.
    func removeKey(_ key: AnyHashable)

    /// Clears all keys from eviction tracking.
    func removeAll()
}
