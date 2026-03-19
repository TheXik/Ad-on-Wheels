import Foundation


// App error representation and mapping from backend errors
enum AppError: LocalizedError, Equatable {
    
    case invalidCredentials // 1001 - Wrong email or password
    case unauthorized // 1002, 1004 - Token expired/invalid
    case accountLocked // 1003 Specific alert
    case profileIncomplete // 2003, 2004 - Navigate to profile setup
    
    // messages from the server for dynamic errors
    case serverMessage(String)
    
    case validation([String: String])
    case networking(String)
    case unknown
    
    // Mapping Backend Codes
    init(backendError: ErrorResponse) {
        // Validation Errors (9001) - Check for detailed map first
        if let validationMap = backendError.validationErrors, !validationMap.isEmpty {
            self = .validation(validationMap)
            return
        }

        switch backendError.internalCode {
        case 1001:
            self = .invalidCredentials
        case 1002, 1004:
            self = .unauthorized
        case 1003:
            self = .accountLocked
        case 2003, 2004:
            self = .profileIncomplete
        default:
            self = .serverMessage(backendError.message)
        }
    }
    
    // Computed property for the UI
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .unauthorized:
            return "Your session has expired. Please login again."
        case .accountLocked:
            return "Your account is locked. Please contact support."
        case .profileIncomplete:
            return "Please complete your profile to continue."
        case .serverMessage(let message):
            return message
        case .validation(let errors):
            return "Please check your input. (\(errors.values.first ?? "Invalid data"))"
        case .networking(let error):
            return "Connection failed. Please check your internet. (\(error))"
        case .unknown:
            return "Something went wrong."
        }
    }
    
}
