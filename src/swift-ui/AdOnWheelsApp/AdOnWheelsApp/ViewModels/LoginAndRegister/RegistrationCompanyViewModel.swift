import Foundation

@MainActor
class RegisterCompanyViewModel: ObservableObject {
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
                             "role": UserRole.company.rawValue.uppercased()])
            )
            let response: RegistrationResponse = try await api.send(endpoint)
            
            // Registration successful, but don't auto-login
            registrationSuccessful = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
