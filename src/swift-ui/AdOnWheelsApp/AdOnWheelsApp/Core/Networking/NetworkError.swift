import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, data: Data?)
    case transport(Error)
    case decoding(Error)

    
    // TODO add errors regarding invalid email and so on from the backend 
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let statusCode, _):
            return "Request failed with status code \(statusCode)"
        case .transport(let underlying):
            return "Network transport error: \(underlying.localizedDescription)"
        case .decoding(let underlying):
            return "Decoding error: \(underlying.localizedDescription)"
        }
    }
}
