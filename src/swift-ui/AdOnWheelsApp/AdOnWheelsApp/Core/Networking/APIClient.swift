import Foundation

protocol APIClientProtocol {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func send(_ endpoint: Endpoint) async throws
}

final class APIClient: APIClientProtocol {
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

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.transport(URLError(.badServerResponse))
        }
        let status = http.statusCode

        // try decoding the standard API wrapper the server returns
        do {
            let apiResponse = try decoder.decode(ApiResponse<T>.self, from: data)

            if apiResponse.success {
                if let responseData = apiResponse.data {
                    return responseData
                } else if T.self == EmptyResponse.self {
                    // Allow success with no data for endpoints that don't return a body.
                    return EmptyResponse() as! T
                } else {
                    throw NetworkError.decoding(URLError(.cannotParseResponse))
                }
            } else if let errorResponse = apiResponse.error {
                throw NetworkError.serverError(errorResponse)
            } else if !(200..<300).contains(status) {
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw NetworkError.serverError(errorResponse)
                } else {
                    throw NetworkError.malformedErrorResponse(statusCode: status)
                }
            } else {
                throw NetworkError.decoding(URLError(.cannotParseResponse))
            }
        } catch {
            // If wrapper decoding failed and status is non-2xx, try to decode a raw ErrorResponse.
            if !(200..<300).contains(status) {
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw NetworkError.serverError(errorResponse)
                } else {
                    throw NetworkError.malformedErrorResponse(statusCode: status)
                }
            } else {
                throw NetworkError.decoding(error)
            }
        }
    }
    
    
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
