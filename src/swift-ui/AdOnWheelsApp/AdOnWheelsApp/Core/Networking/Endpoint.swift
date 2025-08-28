import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let body: Data?

    init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }

    func makeURLRequest(baseURL: URL) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = TokenManager.shared.retrieveToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        if let body = body {
            request.httpBody = body
        }
        return request
       }
}
