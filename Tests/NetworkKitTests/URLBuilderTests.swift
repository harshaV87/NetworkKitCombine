import XCTest
@testable import NetworkKit

final class NetworkKitTests: XCTestCase {
    
    var sut: URLBuilderInterface!
    
    override func setUp() {
        sut = MockURLBuilder()
    }
    
    func testURLComponentsBuilder() {
        let queryItemI = URLQueryItem(name: "i", value: "tt3896198")
        let queryItemApiKey = URLQueryItem(name: "apikey", value: "d9482b5b")
        let testURL = URLComponentsBuilder(scheme: "https", host: "www.omdbapi.com", path: "/", queryItems: [queryItemI, queryItemApiKey])
        XCTAssertEqual(testURL.buildURL(), sut.buildURL())
    }
    
    override func tearDown() {
        sut = nil
    }
}


class MockURLBuilder: URLBuilderInterface {
    func buildURL() -> URL? {
        return URL(string: "https://www.omdbapi.com/?i=tt3896198&apikey=d9482b5b")
    }
    
    
}
