import Foundation

// True for both CancellationError and URLError.cancelled. Used by view models
// to skip surfacing task-cancellation as a user-visible error.
extension Error {
    var isCancellation: Bool {
        if self is CancellationError { return true }
        if let urlError = self as? URLError, urlError.code == .cancelled { return true }
        return false
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case transport(Error)
    case decoding(Error)
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
