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
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.transport(URLError(.badServerResponse))
        }
        
        do {
            let apiResponse = try decoder.decode(ApiResponse<T>.self, from: data)

            // Check for success flag and valid data
            if apiResponse.success, let responseData = apiResponse.data {
                return responseData
                
            } else if
                let errorResponse = apiResponse.error {
                throw NetworkError.serverError(errorResponse)
                
            } else {
                 // as a fallback
                throw NetworkError.decoding(URLError(.cannotParseResponse))
            }
        } catch {
            throw NetworkError.decoding(error)
        }
    }
    
    // The send method without a return type can be simplified
    func send(_ endpoint: Endpoint) async throws {
        let request = try endpoint.makeURLRequest(baseURL: baseURL)
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.transport(URLError(.badServerResponse))
        }
    }

    private static var defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
