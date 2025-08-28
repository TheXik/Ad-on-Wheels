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

    init(api: APIClientProtocol = APIClient.shared) {
        self.api = api
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
            let _: RegistrationResponse = try await api.send(endpoint)
            registrationSuccessful = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
