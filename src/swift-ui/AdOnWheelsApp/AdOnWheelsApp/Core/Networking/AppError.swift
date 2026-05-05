import Foundation

enum AppError: LocalizedError, Equatable {
    
    case invalidCredentials // 1001 - Wrong email or password
    case unauthorized // 1004 - Token invalid
    case roleMismatch(existingRole: UserRole) // 2007 - Email registered under a different role

    case serverMessage(String)

    case validation([String: String])
    case networking(String)
    case unknown

    init(backendError: ErrorResponse) {
        // Validation Errors (9001) - Check for detailed map first
        if let validationMap = backendError.validationErrors, !validationMap.isEmpty {
            self = .validation(validationMap)
            return
        }

        switch backendError.internalCode {
        case 1001:
            self = .invalidCredentials
        case 1004:
            self = .unauthorized
        case 2007:
            let raw = backendError.message.trimmingCharacters(in: .whitespaces).uppercased()
            if raw == "DRIVER" {
                self = .roleMismatch(existingRole: .driver)
            } else if raw == "COMPANY" {
                self = .roleMismatch(existingRole: .company)
            } else {
                self = .serverMessage(backendError.message)
            }
        default:
            self = .serverMessage(backendError.message)
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .unauthorized:
            return nil
        case .roleMismatch(let existingRole):
            return "This email is already registered as a \(existingRole.rawValue)."
        case .serverMessage(let message):
            return message
        case .validation(let errors):
            return errors.values.first ?? "Invalid input."
        case .networking:
            return "No connection."
        case .unknown:
            return "Something went wrong."
        }
    }
    
}
