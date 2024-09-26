import Foundation
@testable import ImageLoader

final class MockCache: Cache {
    private var storage: [AnyHashable: Data] = [:]

    func get(_ key: AnyHashable) async -> Data? {
        return storage[key]
    }

    func set(_ value: Data, for key: AnyHashable) async {
        storage[key] = value
    }

    func remove(_ key: AnyHashable) async {
        storage.removeValue(forKey: key)
    }

    func clear() async {
        storage.removeAll()
    }
}
