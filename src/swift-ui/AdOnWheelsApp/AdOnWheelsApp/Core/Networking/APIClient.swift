import Foundation

protocol APIClientProtocol: Sendable {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func send(_ endpoint: Endpoint) async throws
}

final class APIClient: APIClientProtocol, Sendable {
    static let shared = APIClient(baseURL: AppConfig.baseURL)

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: URL, session: URLSession = .shared, decoder: JSONDecoder = APIClient.defaultDecoder) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        return try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: NetworkError.transport(error))
                    return
                }

                // Fix for "immutable value was never used" warning
                guard let data = data, let _ = response as? HTTPURLResponse else {
                    continuation.resume(throwing: NetworkError.transport(URLError(.badServerResponse)))
                    return
                }

                do {
                    let apiResponse = try self.decoder.decode(ApiResponse<T>.self, from: data)

                    if apiResponse.success, let responseData = apiResponse.data {
                        continuation.resume(returning: responseData)
                    } else if let errorResponse = apiResponse.error {
                        continuation.resume(throwing: NetworkError.serverError(errorResponse))
                    } else {
                        continuation.resume(throwing: NetworkError.decoding(URLError(.cannotParseResponse)))
                    }
                } catch {
                    continuation.resume(throwing: NetworkError.decoding(error))
                }
            }
            task.resume()
        }
    }
    
    // This function was implemented with a recursive call, which is a bug.
    // It should call the generic send<T> function with an EmptyResponse.
    func send(_ endpoint: Endpoint) async throws {
        let _: EmptyResponse = try await send(endpoint)
    }
    
    private struct EmptyResponse: Decodable {}
    
    private static var defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
