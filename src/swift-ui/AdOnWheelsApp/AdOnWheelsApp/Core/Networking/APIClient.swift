import Foundation

protocol APIClientProtocol {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func send(_ endpoint: Endpoint) async throws
    func sendMapped<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func sendMapped(_ endpoint: Endpoint) async throws
    func sendRawData(_ endpoint: Endpoint) async throws -> Data
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient(baseURL: AppConfig.baseURL)
    
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }
    
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        do {
            // Prepare Request
            let request = try endpoint.makeURLRequest(baseURL: baseURL)
            
            // Network Call
            let (data, response) = try await session.data(for: request)

            // Validate HTTP Response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.transport(URLError(.badServerResponse))
            }
            
            // Handle Success (200-299)
            if (200...299).contains(httpResponse.statusCode) {
                // Handle Empty Response Case
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                
                // Decode the Standard ApiResponse Wrapper
                let apiResponse = try decoder.decode(ApiResponse<T>.self, from: data)
                
                if apiResponse.success, let data = apiResponse.data {
                    return data
                } else if let errorDetails = apiResponse.error {
                    // The server replied 200 OK, but said success=false (Logical Error)
                    throw NetworkError.serverError(errorDetails)
                } else {
                    throw NetworkError.decoding(URLError(.cannotParseResponse))
                }
            }
            
            // Non-2xx: attempt to surface structured error messages
            if let wrapped = try? decoder.decode(ApiResponse<EmptyResponse>.self, from: data),
               let details = wrapped.error {
                throw NetworkError.serverError(details)
            }

            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse)
            }

            throw NetworkError.malformedErrorResponse(statusCode: httpResponse.statusCode)
            
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            throw NetworkError.transport(urlError)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
    
    func send(_ endpoint: Endpoint) async throws {
        let _: EmptyResponse = try await send(endpoint)
    }

    // Convenience wrappers that map NetworkError to AppError
    func sendMapped<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        do {
            return try await send(endpoint)
        } catch {
            throw AppErrorMapper.map(error)
        }
    }

    func sendMapped(_ endpoint: Endpoint) async throws {
        do {
            let _: EmptyResponse = try await send(endpoint)
        } catch {
            throw AppErrorMapper.map(error)
        }
    }
    
    /// Download raw bytes (e.g. CSV export) without JSON decoding.
    func sendRawData(_ endpoint: Endpoint) async throws -> Data {
        do {
            let request = try endpoint.makeURLRequest(baseURL: baseURL)
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.transport(URLError(.badServerResponse))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.malformedErrorResponse(statusCode: httpResponse.statusCode)
            }

            return data
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            throw NetworkError.transport(urlError)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    private struct EmptyResponse: Decodable {}
}
