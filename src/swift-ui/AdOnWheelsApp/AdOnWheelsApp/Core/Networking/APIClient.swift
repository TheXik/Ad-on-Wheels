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
            let request = try endpoint.makeURLRequest(baseURL: baseURL)
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.transport(URLError(.badServerResponse))
            }

            // The gateway returns Spring's default error JSON for an expired/invalid JWT,
            // which doesn't match ApiResponse<T>. Short-circuit before decode and notify
            // the app root so it can sign the user out.
            if httpResponse.statusCode == 401 {
                NotificationCenter.default.post(name: .authTokenExpired, object: nil)
                throw AppError.unauthorized
            }

            if (200...299).contains(httpResponse.statusCode) {
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }

                let apiResponse = try decoder.decode(ApiResponse<T>.self, from: data)

                if apiResponse.success, let data = apiResponse.data {
                    return data
                } else if let errorDetails = apiResponse.error {
                    throw NetworkError.serverError(errorDetails)
                } else {
                    throw NetworkError.decoding(URLError(.cannotParseResponse))
                }
            }

            if let wrapped = try? decoder.decode(ApiResponse<EmptyResponse>.self, from: data),
               let details = wrapped.error {
                throw NetworkError.serverError(details)
            }

            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse)
            }

            throw NetworkError.malformedErrorResponse(statusCode: httpResponse.statusCode)

        } catch let appError as AppError {
            throw appError
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

    func uploadImages(campaignId: Int, images: [Data]) async throws -> Campaign {
        let boundary = UUID().uuidString
        var body = Data()

        for (index, imageData) in images.enumerated() {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let path = "api/campaigns/\(campaignId)/images"

        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = TokenManager.shared.retrieveToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.malformedErrorResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        let apiResponse = try decoder.decode(ApiResponse<Campaign>.self, from: data)
        guard apiResponse.success, let campaign = apiResponse.data else {
            throw NetworkError.decoding(URLError(.cannotParseResponse))
        }
        return campaign
    }

    private struct EmptyResponse: Decodable {}
}

extension Notification.Name {
    /// Posted by `APIClient` when the gateway returns 401. The app root subscribes
    /// and forces a sign-out; UI should show a transient "Session expired" toast.
    static let authTokenExpired = Notification.Name("auth.tokenExpired")
}
