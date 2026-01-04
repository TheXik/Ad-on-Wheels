import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: ErrorResponse?
}

struct ErrorResponse: Decodable, Error {
    let internalCode: Int
    let message: String
    let validationErrors: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case internalCode = "internalCode"
        case message = "message"
        case validationErrors = "validationErrors"
    }
}
