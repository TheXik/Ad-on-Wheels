import Foundation

@MainActor
class RegisterDriverViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registrationSuccessful = false

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
    }

    func register() async {
        isLoading = true
        errorMessage = nil
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
            errorMessage = error.localizedDescription
        }
    }
}
