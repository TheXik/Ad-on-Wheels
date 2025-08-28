// In file AdOnWheelsApp/Core/Networking/NetworkError.swift

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case serverError(ErrorResponse)
    case transport(Error)
    case decoding(Error)
    case malformedErrorResponse(statusCode: Int) // New case for fallback

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError(let errorResponse):
            return errorResponse.message // Use the message from the server!
        case .transport(let underlying):
            return "Network transport error: \(underlying.localizedDescription)"
        case .decoding(let underlying):
            return "Decoding error: \(underlying.localizedDescription)"
        case .malformedErrorResponse(let statusCode):
            return "Received an invalid error format from the server (Status: \(statusCode))"
        }
    }
}
