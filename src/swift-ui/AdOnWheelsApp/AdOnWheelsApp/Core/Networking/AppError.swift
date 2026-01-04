import Foundation


// App error representation and mapping from backend errors
enum AppError: LocalizedError, Equatable {
    
    case unauthorized // 1001, 1002, 1004 - Auth errors
    case accountLocked // 1003 Specific alert
    case profileIncomplete // 2003, 2004 - Navigate to profile setup
    
    // messages from the server for dynamic errors
    case serverMessage(String)
    
    case networking(String)
    case unknown
    
    // Mapping Backend Codes
    init(backendError: ErrorResponse) {
        switch backendError.internalCode {
        case 1001, 1002, 1004:
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
        case .unauthorized:
            // TODO: navigate to login
            return "Your session has expired. Please login again."
        case .accountLocked:
            return "Your account is locked. Please contact support."
        case .profileIncomplete:
            return "Please complete your profile to continue."
        case .serverMessage(let message):
            return message
        case .networking(let error):
            return "Connection failed. Please check your internet. (\(error))"
        case .unknown:
            return "Something went wrong."
        }
    }
    
}
