import Foundation
#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

// MARK: - ImageLoader Protocol

/// A protocol that defines an asynchronous image loader.
public protocol ImageLoader {
    /// Loads an image from the specified URL.
    /// - Parameter url: The URL to load the image from.
    /// - Returns: The image fetched from the provided URL or `nil` if unable to load.
    func loadImage(from url: URL) async throws -> PlatformImage?
}

// MARK: - AsyncImageLoader

public final class CachedImageLoader: ImageLoader {
    private let cache: Cache
    private let dataLoader: DataLoader

    public init(
        cache: Cache,
        dataLoader: DataLoader
    ) {
        self.cache = cache
        self.dataLoader = dataLoader
    }

    public static var `default` = CachedImageLoader(
        cache: MemoryCache(maxSize: 50, evictionStrategy: LRUEvictionStrategy()),
        dataLoader: URLSessionDataLoader()
    )

    public func loadImage(from url: URL) async throws -> PlatformImage? {
        if let cachedData = await cache.get(url) {
            return convertToImage(from: cachedData)
        }

        let data = try await dataLoader.loadResource(from: url)

        await cache.set(data, for: url)

        return convertToImage(from: data)
    }
}

private extension CachedImageLoader {
    func convertToImage(from data: Data) -> PlatformImage? {
#if canImport(UIKit)
        return UIImage(data: data)
#elseif canImport(AppKit)
        return NSImage(data: data)
#endif
    }
}

