import Foundation

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var resetCode = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var step: Step = .enterEmail
    @Published var resetComplete = false

    private let api: APIClientProtocol

    enum Step {
        case enterEmail
        case enterCode
    }

    init(api: APIClientProtocol = APIClient.shared) {
        self.api = api
    }

    var canRequestCode: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@")
    }

    var canResetPassword: Bool {
        !resetCode.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }

    var passwordMismatch: Bool {
        !confirmPassword.isEmpty && newPassword != confirmPassword
    }

    func requestResetCode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let body = try JSONEncoder().encode(["email": email])
            let endpoint = Endpoint(path: "auth/forgot-password", method: .post, body: body)
            let _: String = try await api.send(endpoint)
            step = .enterCode
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPassword() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            struct ResetRequest: Encodable {
                let email: String
                let resetCode: String
                let newPassword: String
            }
            let request = ResetRequest(email: email, resetCode: resetCode, newPassword: newPassword)
            let body = try JSONEncoder().encode(request)
            let endpoint = Endpoint(path: "auth/reset-password", method: .post, body: body)
            let _: String = try await api.send(endpoint)
            resetComplete = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
