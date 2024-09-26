import XCTest
@testable import ImageLoader

// Memory cache tests uses the real implementation of LRUEvictionStrategy
final class MemoryCacheTests: XCTestCase {
    // Test for set and get caching behavior
    func testSetAndGet() async {
        let evictionStrategy = LRUEvictionStrategy()
        let cache = MemoryCache(maxSize: 2, evictionStrategy: evictionStrategy)
        
        await cache.set("value1".data(using: .utf8)!, for: "key1")
        let result = await cache.get("key1")
        
        XCTAssertEqual(String(data: result!, encoding: .utf8), "value1", "The cache should return 'value1' for 'key1'.")
    }
    
    // Test for removing an item from the cache
    func testRemove() async {
        let evictionStrategy = LRUEvictionStrategy()
        let cache = MemoryCache(maxSize: 2, evictionStrategy: evictionStrategy)
        
        await cache.set("value1".data(using: .utf8)!, for: "key1")
        await cache.remove("key1")
        let result = await cache.get("key1")
        
        XCTAssertNil(result, "The cache should return nil after removing 'key1'.")
    }
    
    // Test for clearing the cache
    func testClear() async {
        let evictionStrategy = LRUEvictionStrategy()
        let cache = MemoryCache(maxSize: 2, evictionStrategy: evictionStrategy)
        
        await cache.set("value1".data(using: .utf8)!, for: "key1")
        await cache.set("value2".data(using: .utf8)!, for: "key2")
        await cache.clear()
        
        let result1 = await cache.get("key1")
        let result2 = await cache.get("key2")
        
        XCTAssertNil(result1, "The cache should return nil after clearing.")
        XCTAssertNil(result2, "The cache should return nil after clearing.")
    }
    
    // Test for eviction when cache exceeds maximum size
    func testEviction() async {
        let evictionStrategy = LRUEvictionStrategy()
        let cache = MemoryCache(maxSize: 2, evictionStrategy: evictionStrategy)
        
        await cache.set("value1".data(using: .utf8)!, for: "key1")
        await cache.set("value2".data(using: .utf8)!, for: "key2")

        // This should trigger eviction as the max size is 2
        await cache.set("value3".data(using: .utf8)!, for: "key3")

        let result1 = await cache.get("key1")
        let result2 = await cache.get("key2")
        let result3 = await cache.get("key3")
        
        XCTAssertNil(result1, "The cache should evict 'key1'.")
        XCTAssertEqual(String(data: result2!, encoding: .utf8), "value2", "The cache should still contain 'key2'.")
        XCTAssertEqual(String(data: result3!, encoding: .utf8), "value3", "The cache should contain 'key3'.")
    }
    
    // Test eviction and access tracking behavior
    func testEvictionAndAccessTracking() async {
        let evictionStrategy = LRUEvictionStrategy()
        let cache = MemoryCache(maxSize: 2, evictionStrategy: evictionStrategy)
        
        await cache.set("value1".data(using: .utf8)!, for: "key1")
        await cache.set("value2".data(using: .utf8)!, for: "key2")

        // Access key1, making it the most recently used
        _ = await cache.get("key1")
        
        // Add key3, this should evict the least recently key2 in this case
        await cache.set("value3".data(using: .utf8)!, for: "key3")

        let result1 = await cache.get("key1")
        let result2 = await cache.get("key2")
        let result3 = await cache.get("key3")
        
        XCTAssertEqual(String(data: result1!, encoding: .utf8), "value1", "The cache should still contain 'key1'.")
        XCTAssertNil(result2, "The cache should evict 'key2'.")
        XCTAssertEqual(String(data: result3!, encoding: .utf8), "value3", "The cache should contain 'key3'.")
    }
}
