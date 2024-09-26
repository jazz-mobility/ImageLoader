import XCTest
@testable import ImageLoader

final class LRUEvictionStrategyTests: XCTestCase {
    func testTrackAccess_addsKeyToCache() async {
        let sut = LRUEvictionStrategy<String>()
        
        // Access key1, this inserts the key1
        sut.trackAccess(for: "key1")
        
        XCTAssertEqual(sut.keyToEvict(), "key1", "Only key in the cache should be key1")
    }
    
    func testTrackAccess_updatesOrder() {
        let evictionStrategy = LRUEvictionStrategy<String>()
        
        evictionStrategy.trackAccess(for: "key1")
        evictionStrategy.trackAccess(for: "key2")
        evictionStrategy.trackAccess(for: "key3")
        
        // key1 is the least recently used
        XCTAssertEqual(evictionStrategy.keyToEvict(), "key1", "Least recently used key should be key1")
        
        // Access key1, making it the most recently used
        evictionStrategy.trackAccess(for: "key1")
        
        // Now key2 should be the least recently used
        XCTAssertEqual(evictionStrategy.keyToEvict(), "key2", "Least recently used key should be key2")
    }
    
    func testEvictionPolicy_evictsLeastRecentlyUsedKey() {
        let evictionStrategy = LRUEvictionStrategy<String>()
        
        evictionStrategy.trackAccess(for: "key1")
        evictionStrategy.trackAccess(for: "key2")
        evictionStrategy.trackAccess(for: "key3")
        
        XCTAssertEqual(evictionStrategy.keyToEvict(), "key1", "Least recently used key should be key1")
        
        // Remove the least recently
        evictionStrategy.removeKey("key1")
        
        // Now key2 should be the least recently used
        XCTAssertEqual(evictionStrategy.keyToEvict(), "key2", "Least recently used key should be key2")
    }
    
    func testRemoveKey_removesKeyFromCache() {
        let evictionStrategy = LRUEvictionStrategy<String>()
        
        evictionStrategy.trackAccess(for: "key1")
        evictionStrategy.trackAccess(for: "key2")
        
        // Remove key1
        evictionStrategy.removeKey("key1")
        
        // key2 should now be the only key left
        XCTAssertEqual(evictionStrategy.keyToEvict(), "key2", "The remaining key should be key2")
        
        // Ensure key1 is no longer in the cache
        evictionStrategy.removeKey("key1")
        XCTAssertNotEqual(evictionStrategy.keyToEvict(), "key1", "key1 should have been removed")
    }
    
    func testRemoveAll_clearsAllKeys() {
        let evictionStrategy = LRUEvictionStrategy<String>()
        
        evictionStrategy.trackAccess(for: "key1")
        evictionStrategy.trackAccess(for: "key2")
        
        // Clears the cache
        evictionStrategy.removeAll()
        
        XCTAssertNil(evictionStrategy.keyToEvict(), "Cache should be empty after removeAll.")
    }
}
