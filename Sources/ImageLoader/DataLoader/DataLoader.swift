import Foundation

/// A protocol that defines a mechanism for asynchronously loading data from a given URL.
public protocol DataLoader {
    
    /// Loads the data from the specified URL.
    /// - Parameter url: The URL to load the resource from.
    /// - Returns: The data fetched from the provided URL.
    /// - Throws: An error if the resource cannot be loaded.
    func loadResource(from url: URL) async throws -> Data
}
