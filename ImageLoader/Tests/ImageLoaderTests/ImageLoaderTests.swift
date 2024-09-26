import XCTest
@testable import ImageLoader

final class ImageLoaderTests: XCTestCase {
    var imageLoader: CachedImageLoader!
    var mockCache: MockCache!
    var mockDataLoader: MockDataLoader!

    override func setUp() {
        super.setUp()
        mockCache = MockCache()
        mockDataLoader = MockDataLoader()
        imageLoader = CachedImageLoader(cache: mockCache, dataLoader: mockDataLoader)
    }

    override func tearDown() {
        imageLoader = nil
        mockCache = nil
        mockDataLoader = nil
        super.tearDown()
    }

    func testCachedImageReturnsFromCache() async throws {
        let url = URL(string: "https://via.placeholder.com/150")!
        let imageData = getSystemImageData()
        await mockCache.set(imageData, for: url)

        let image = try await imageLoader.loadImage(from: url)

        XCTAssertNotNil(image)
        XCTAssertEqual(getSystemImageData(), imageData)
    }

    func testImageLoadsFromNetworkIfNotInCache() async throws {
        let url = URL(string: "https://via.placeholder.com/150")!
        let imageData = getSystemImageData()
        mockDataLoader.data = imageData

        let image = try await imageLoader.loadImage(from: url)

        XCTAssertNotNil(image)
        XCTAssertEqual(getSystemImageData(), imageData)

        // ensure the image is cached
        let cachedData = await mockCache.get(url)
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData, imageData)
    }

    func testImageLoadFailsWithNetworkError() async {
        let url = URL(string: "https://via.placeholder.com/150")!
        mockDataLoader.shouldSucceed = false

        do {
            _ = try await imageLoader.loadImage(from: url)
            XCTFail("Expected to throw an error, but did not")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    // Test: Verify image is cached after fetching from the network
    func testImageIsCachedAfterFetchingFromNetwork() async throws {
        let url = URL(string: "https://via.placeholder.com/150")!
        let imageData = getSystemImageData()
        mockDataLoader.data = imageData

        _ = try await imageLoader.loadImage(from: url)

        // After fetching from network, the image should be cached
        let cachedData = await mockCache.get(url)
        XCTAssertNotNil(cachedData)
        XCTAssertEqual(cachedData, getSystemImageData())
    }
}

private extension ImageLoaderTests {
    func getSystemImageData() -> Data {
#if canImport(UIKit)
        return UIImage(systemName: "star.fill")!.pngData()!
#elseif canImport(AppKit)
        let image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)!
        let data = image.tiffRepresentation!
        return data
#endif
    }
}
