import Foundation

// Converts technical errors into UI errors
enum AppErrorMapper {
    static func map(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        // Handle NetworkError
        if let networkError = error as? NetworkError {
            switch networkError {
            case .serverError(let response):
                return AppError(backendError: response)
            case .transport(let underlying):
                if let urlError = underlying as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost, .cannotConnectToHost:
                        return .networking(urlError.localizedDescription)
                    default:
                        return .networking(urlError.localizedDescription)
                    }
                }
                return .networking(underlying.localizedDescription)
            case .decoding(let underlying):
                return .networking("Failed to parse response: \(underlying.localizedDescription)")
            case .malformedErrorResponse(let statusCode):
                return .networking("Server error (Status: \(statusCode))")
            case .invalidURL:
                return .networking("Invalid request configuration")
            }
        }
        
        // Fallback for any other error type
        return .unknown
    }
}
