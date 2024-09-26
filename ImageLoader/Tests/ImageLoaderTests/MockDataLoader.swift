import Foundation
@testable import ImageLoader

final class MockDataLoader: DataLoader {
    var shouldSucceed = true
    var data: Data?

    func loadResource(from url: URL) async throws -> Data {
        if shouldSucceed, let data = data {
            return data
        } else {
            throw URLError(.badServerResponse)
        }
    }
}
