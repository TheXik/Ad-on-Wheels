import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case serverError(ErrorResponse)
    case malformedErrorResponse(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError(let response):
            return "Server Error \(response.internalCode): \(response.message)"
        case .transport(let underlying):
            return "Network transport error: \(underlying.localizedDescription)"
        case .decoding(let underlying):
            return "Decoding error: \(underlying.localizedDescription)"
        case .malformedErrorResponse(let statusCode):
            return "Server returned invalid error format (Status: \(statusCode))"
        }
    }
}