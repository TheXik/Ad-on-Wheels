import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: ErrorResponse?
}

struct ErrorResponse: Decodable, LocalizedError {
    let status: Int
    let message: String

    var errorDescription: String? {
        return message
    }
}
