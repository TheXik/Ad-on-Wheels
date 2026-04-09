import Foundation

@MainActor
class RegisterDriverViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registrationSuccessful = false
    @Published var fieldErrors: [String: String] = [:]
    @Published var roleMismatch: UserRole?
    @Published var pendingGoogleIdToken: String?

    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        let pred = NSPredicate(format: "SELF MATCHES %@",
                               "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$")
        return pred.evaluate(with: trimmed)
    }

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
    }

    func register() async {
        isLoading = true
        errorMessage = nil
        fieldErrors = [:]
        registrationSuccessful = false
        defer { isLoading = false }

        do {
            let endpoint = Endpoint(
                path: "auth/register",
                method: .post,
                body: try JSONEncoder()
                    .encode(["email": email,
                             "password": password,
                             "name": name,
                             "role": UserRole.driver.rawValue.uppercased()])
            )
            let response: RegistrationResponse = try await api.sendMapped(endpoint)
            
            // Auto-login with the token received from registration
            authService.didLogin(token: response.token)
            registrationSuccessful = true
        } catch {
            if let appError = error as? AppError, case .roleMismatch(let existing) = appError {
                self.pendingGoogleIdToken = nil
                self.roleMismatch = existing
            } else if let appError = error as? AppError, case .validation(let errors) = appError {
                self.fieldErrors = errors
                self.errorMessage = "Please fix the errors below."
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }

    func loginAsExistingRole(_ role: UserRole) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response: LoginResponse
            if let idToken = pendingGoogleIdToken {
                let endpoint = Endpoint(
                    path: "auth/google",
                    method: .post,
                    body: try JSONEncoder()
                        .encode(["idToken": idToken, "role": role.rawValue.uppercased()])
                )
                response = try await api.sendMapped(endpoint)
            } else {
                let endpoint = Endpoint(
                    path: "auth/login",
                    method: .post,
                    body: try JSONEncoder().encode(["email": email, "password": password])
                )
                response = try await api.sendMapped(endpoint)
            }
            pendingGoogleIdToken = nil
            authService.didLogin(token: response.token)
            return true
        } catch {
            pendingGoogleIdToken = nil
            if let appError = error as? AppError, case .invalidCredentials = appError {
                errorMessage = "Incorrect password. Please log in manually."
            } else {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
}
