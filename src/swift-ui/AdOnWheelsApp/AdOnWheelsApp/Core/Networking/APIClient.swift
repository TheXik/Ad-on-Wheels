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
        do {
            let (data, response) = try await session.data(for: request)
            try Self.throwIfInvalidStatus(response: response, data: data)
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decoding(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error)
        }
    }

    func send(_ endpoint: Endpoint) async throws {
        let request = try endpoint.makeURLRequest(baseURL: baseURL)
        do {
            let (data, response) = try await session.data(for: request)
            try Self.throwIfInvalidStatus(response: response, data: data)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error)
        }
    }

    private static var defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private static func throwIfInvalidStatus(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200...299:
            return
        default:
            throw NetworkError.requestFailed(statusCode: http.statusCode, data: data)
        }
    }
}
