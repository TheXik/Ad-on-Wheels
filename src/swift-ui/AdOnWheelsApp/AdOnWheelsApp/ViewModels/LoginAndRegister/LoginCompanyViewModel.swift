import Foundation

@MainActor
class LoginCompanyViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: APIClientProtocol

    init(api: APIClientProtocol = APIClient.shared) {
        self.api = api
    }

    func login() async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let endpoint = Endpoint(
                path: "auth/login",
                method: .post,
                body: try JSONEncoder().encode(["email": email, "password": password])
            )
            let response: LoginResponse = try await api.send(endpoint)
            try TokenManager.shared.save(token: response.token)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
