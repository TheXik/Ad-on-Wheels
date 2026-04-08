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
            if let appError = error as? AppError, case .validation(let errors) = appError {
                self.fieldErrors = errors
                self.errorMessage = "Please fix the errors below."
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}
