import XCTest
@testable import ImageLoader

final class CachedImageLoaderIntegrationTests: XCTestCase {
    var imageLoader: CachedImageLoader!
    var cache: MemoryCache!

    override func setUp() {
        super.setUp()
        let evictionStrategy = LRUEvictionStrategy()
        cache = MemoryCache(maxSize: 50, evictionStrategy: evictionStrategy)
        let dataLoader = URLSessionDataLoader(session: .shared)
        imageLoader = CachedImageLoader(cache: cache, dataLoader: dataLoader)
    }

    override func tearDown() {
        imageLoader = nil
        cache = nil
        super.tearDown()
    }

    func testImageLoadsFromNetworkAndIsCached() async throws {
        let url = URL(string: "https://via.placeholder.com/150")!

        let cachedData = await cache.get(url)
        XCTAssertNil(cachedData, "Image should not be in cache initially")

        let image = try await imageLoader.loadImage(from: url)
        XCTAssertNotNil(image, "Image should be loaded from network")

        let newCachedData = await cache.get(url)
        XCTAssertNotNil(newCachedData, "Image should be cached after network fetch")
    }

    func testNetworkErrorHandling() async throws {
        let invalidURL = URL(string: "https://someurl.com/no.png")!

        do {
            _ = try await imageLoader.loadImage(from: invalidURL)
            XCTFail("Expected to throw an error for an invalid URL, but did not")
        } catch {
            XCTAssertTrue(error is URLError, "Should throw URLError on network failure")
        }
    }
}
