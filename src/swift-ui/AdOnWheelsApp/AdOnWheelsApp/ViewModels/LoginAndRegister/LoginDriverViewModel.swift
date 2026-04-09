import Foundation

@MainActor
class LoginDriverViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var fieldErrors: [String: String] = [:]
    @Published var roleMismatch: UserRole?

    private let api: APIClientProtocol

    init(api: APIClientProtocol = APIClient.shared) {
        self.api = api
    }

    func login() async -> String? {
        isLoading = true
        errorMessage = nil
        fieldErrors = [:]
        defer { isLoading = false }

        do {
            let endpoint = Endpoint(
                path: "auth/login",
                method: .post,
                body: try JSONEncoder().encode([
                    "email": email,
                    "password": password,
                    "expectedRole": UserRole.driver.rawValue.uppercased()
                ])
            )
            let response: LoginResponse = try await api.sendMapped(endpoint)
            return response.token
        } catch {
            if let appError = error as? AppError, case .roleMismatch(let existing) = appError {
                self.roleMismatch = existing
            } else if let appError = error as? AppError, case .validation(let errors) = appError {
                self.fieldErrors = errors
                self.errorMessage = "Please fix the errors below."
            } else {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }

    func loginAsExistingRole() async -> String? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let endpoint = Endpoint(
                path: "auth/login",
                method: .post,
                body: try JSONEncoder().encode(["email": email, "password": password])
            )
            let response: LoginResponse = try await api.sendMapped(endpoint)
            return response.token
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
