import Combine
import Foundation

@available(iOS 13.0, *)
public protocol NetworkServiceInterface {
    // just returning any publisher
    var session: URLSession {get set}
    func fetchData<T: Decodable>(from URLBuilder: URLBuilderInterface, response: T.Type) -> AnyPublisher<T,NetworkServiceError>
}


// Service
@available(iOS 13.0, *)
public class NetworkService: NetworkServiceInterface {
     public var session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func fetchData<T>(from URLBuilder: any URLBuilderInterface, response: T.Type) -> AnyPublisher<T, NetworkServiceError> where T : Decodable {
        // return error if the url is wrong
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
            }.eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkServiceError.badURLString).eraseToAnyPublisher()
        }
    }
}

