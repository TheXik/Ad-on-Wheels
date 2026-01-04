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
            
            // Registration successful, but don't auto-login
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
