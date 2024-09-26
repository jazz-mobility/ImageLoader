import XCTest
@testable import ImageLoader

final class URLSessionDataLoaderTests: XCTestCase {
    var session: URLSession!
    var dataLoader: URLSessionDataLoader!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)

        dataLoader = URLSessionDataLoader(session: session)
    }

    override func tearDown() {
        session = nil
        dataLoader = nil

        super.tearDown()
    }

    func testSuccessfullDataLoad() async throws {
        let expectedData = "Hello, World!".data(using: .utf8)!
        let url = URL(string: "https://hello.com/world")!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, expectedData)
        }

        let data = try await dataLoader.loadResource(from: url)

        XCTAssertEqual(data, expectedData, "Data loaded from the URL should match the expected data.")
    }

    func testBadServerResponseError() async throws {
        let url = URL(string: "https://hello.com/world")!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            _ = try await dataLoader.loadResource(from: url)
            XCTFail("Expected URLError.badServerResponse but no errors were thrown.")
        } catch {
            XCTAssertTrue(error is URLError)
            XCTAssertEqual((error as? URLError)?.code, .badServerResponse, "Error should be URLError.badServerResponse")
        }
    }

    func testReusesOngoingTask() async throws {
        let url = URL(string: "https://hello.com/world")!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, "\(Date())".data(using: .utf8)!) // setting date as expected data to check the same response
        }

        // trigger multiple requests for same url
        async let firstRequest = try await dataLoader.loadResource(from: url)
        async let secondRequest = try await dataLoader.loadResource(from: url)

        let firstResult = try await firstRequest
        let secondResult = try await secondRequest
        XCTAssertEqual(firstResult, secondResult, "Both requests should return the same data.")
    }
}
