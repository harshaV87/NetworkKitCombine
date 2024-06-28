//
//  NetworkServiceTests.swift
//  
//
//  Created by BV Harsha on 2024-06-26.
//

import XCTest
import Combine
@testable import NetworkKit

final class NetworkServiceTests: XCTestCase {

    var sut : NetworkServiceInterface!
    var cancellables = Set<AnyCancellable>()
    var builderInterface : URLBuilderInterface = MockURLBuilder(URLValidFlag: true)
    
    override func setUp() {
        super.setUp()
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLDataInterface.self]
        sut = MockNetworkService(session: URLSession(configuration: sessionConfig), URLBuilder: builderInterface)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        cancellables = []
    }
    
    // Data available, right status response, right object to decode
    func testDataAvailableCorrectParsingWithRightStatusCode() {
        let expectation = XCTestExpectation(description: "Data available")
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLDataInterface.self]
       // Inject mock dependency
        MockURLDataInterface.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, MockData.returnDataFromMock())
        }
        sut.fetchData(from: builderInterface, response: MovieSearch.self).sink { completion in
            // status of completion
            switch completion {
            case .finished:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error: \(error.localizedDescription)")
            }
        } receiveValue: { movieObject in
            XCTAssertEqual(movieObject.country, "United States")
            XCTAssertEqual(movieObject.language, "English")
        }.store(in: &cancellables)
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Data available, wrong status response, right object to decode
    
    func testDataAvailableCorrectParsingWithWrongStatusCode() {
        let expectation = XCTestExpectation(description: "Data available, Wrong status code")
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLDataInterface.self]
       // Inject mock dependency
        MockURLDataInterface.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, MockData.returnDataFromMock())
        }
        sut.fetchData(from: builderInterface, response: MovieSearch.self).sink { completion in
            // status of completion
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "The request has failed. Error: The response code is not acceptable , response: 400")
                expectation.fulfill()
            }
        } receiveValue: { _ in
            XCTFail()
        }.store(in: &cancellables)
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Data not available, right status response, right object to decode
    
    func testNoDataAvailableCorrectParsingWithRightStatusCode() {
        let expectation = XCTestExpectation(description: "No Data unavailable")
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLDataInterface.self]
       // Inject mock dependency
        MockURLDataInterface.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        sut.fetchData(from: builderInterface, response: MovieSearch.self).sink { completion in
            // status of completion
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "No data")
                expectation.fulfill()
            }
        } receiveValue: { _ in
            XCTFail()
        }.store(in: &cancellables)
        expectation.isInverted = true
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Data available, right status response, wrong object to decode
    
    func testDataAvailableWrongParsingWithRightStatusCode() {
        let expectation = XCTestExpectation(description: "Decoding error")
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLDataInterface.self]
       // Inject mock dependency
        MockURLDataInterface.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, MockData.returnDataFromMock())
        }
        sut.fetchData(from: builderInterface, response: String.self).sink { completion in
            // status of completion
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "The decoding has failed. Errorr: The data couldn’t be read because it isn’t in the correct format.")
                expectation.fulfill()
            }
        } receiveValue: { _ in
            XCTFail()
        }.store(in: &cancellables)
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Wrong URL construct
    func testUnacceptableURLConstruct() {
        let expectation = XCTestExpectation(description: "Unacceptable URL construct")
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.protocolClasses = [MockURLDataInterface.self]
       // Inject mock dependency
        MockURLDataInterface.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, MockData.returnDataFromMock())
        }
        sut.fetchData(from: MockURLBuilder(URLValidFlag: false), response: MovieSearch.self).sink { completion in
            // status of completion
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "The URL construct is wrong")
                expectation.fulfill()
            }
        } receiveValue: { _ in
            XCTFail()
        }.store(in: &cancellables)
        wait(for: [expectation], timeout: 1.0)
    }

}





// Mock network class

class MockNetworkService : NetworkServiceInterface {
    
    var session: URLSession
    var URLBuilder: URLBuilderInterface
  
    init(session: URLSession, URLBuilder: URLBuilderInterface) {
        self.session = session
        self.URLBuilder = URLBuilder
    }
    
    func fetchData<T>(from URLBuilder: any NetworkKit.URLBuilderInterface, response: T.Type) -> AnyPublisher<T, NetworkKit.NetworkServiceError> where T : Decodable {
        do {
            guard ((try URLBuilder.isValidURL()) == true) else {return Fail(error: NetworkServiceError.badURLString).eraseToAnyPublisher()}
            guard let url = URLBuilder.buildURL() else {return Fail(error: NetworkServiceError.badURLString).eraseToAnyPublisher()}
            // return the publisher
            return session.dataTaskPublisher(for: url)
                .tryMap({ result in
                    // Checking for proper httpresponse and code
                    guard let httpResponse = result.response as? HTTPURLResponse else {
                        throw NetworkServiceError.requestFailed(URLError(.badServerResponse))
                    }
                    guard 200..<300 ~= httpResponse.statusCode else {
                        throw NetworkServiceError.badHTTPResponseCode(httpResponse.statusCode)
                    }
                    return result
                })
                .mapError{NetworkServiceError.requestFailed($0)}.flatMap { data, response -> AnyPublisher<T, NetworkServiceError> in
                return Just(data).decode(type: T.self, decoder: JSONDecoder()).mapError { NetworkServiceError.decodingFailed($0)}.eraseToAnyPublisher()
                }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkServiceError.badURLString).eraseToAnyPublisher()
        }
    }
}
