import Foundation
import GoogleSignIn

@MainActor
class LoginCompanyViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var fieldErrors: [String: String] = [:]

    private let api: APIClientProtocol
    private let googleClientID = "1009636850818-ju60fnmur0s7dvlr0qrp0cujl7u1l3e2.apps.googleusercontent.com"

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
                body: try JSONEncoder().encode(["email": email, "password": password])
            )
            let response: LoginResponse = try await api.sendMapped(endpoint)
            return response.token
        } catch {
            if let appError = error as? AppError, case .validation(let errors) = appError {
                self.fieldErrors = errors
                self.errorMessage = "Please fix the errors below."
            } else {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }

    func loginWithGoogle() async -> String? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presenter = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to present Google Sign-In."
            return nil
        }

        do {
            let config = GIDConfiguration(clientID: googleClientID)
            GIDSignIn.sharedInstance.configuration = config

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Google Sign-In did not return an ID token."
                return nil
            }

            let endpoint = Endpoint(
                path: "auth/google",
                method: .post,
                body: try JSONEncoder().encode(["idToken": idToken])
            )
            let response: LoginResponse = try await api.sendMapped(endpoint)
            return response.token
        } catch let error as GIDSignInError where error.code == .canceled {
            return nil
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
