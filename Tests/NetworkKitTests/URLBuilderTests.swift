import XCTest
@testable import NetworkKit

final class NetworkKitTests: XCTestCase {
    
    var sut: URLBuilderInterface!
    
    override func setUp() {
        super.setUp()
        sut = MockURLBuilder(URLValidFlag: true)
    }
    
    func testURLComponentsBuilderSuccess() {
        let queryItemI = URLQueryItem(name: "i", value: "tt3896198")
        let queryItemApiKey = URLQueryItem(name: "apikey", value: "d9482b598798b")
        let testURL = URLComponentsBuilder(scheme: "https", host: "www.omdbapi.com", path: "/", queryItems: [queryItemI, queryItemApiKey])
        XCTAssertEqual( try testURL.isValidURL(), true)
        XCTAssertEqual(testURL.buildURL(),sut.buildURL())
    }
    
    override func tearDown() {
       super.tearDown()
        sut = nil
    }
}


class MockURLBuilder: URLBuilderInterface {
    
    var URLValidFlag: Bool
    
    init(URLValidFlag: Bool) {
        self.URLValidFlag = URLValidFlag
    }
    
    func isValidURL() throws -> Bool {
        return URLValidFlag
    }
    
    func buildURL() -> URL? {
        return URL(string: "https://www.omdbapi.com/?i=tt3896198&apikey=d9482b598798b")
    }
}
