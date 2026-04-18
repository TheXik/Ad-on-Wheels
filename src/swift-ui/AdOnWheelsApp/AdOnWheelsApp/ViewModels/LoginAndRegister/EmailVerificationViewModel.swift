import Foundation

@MainActor
class EmailVerificationViewModel: ObservableObject {
    @Published var code = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isVerified = false
    @Published var codeSent = false

    let email: String
    private let api: APIClientProtocol

    init(email: String, api: APIClientProtocol = APIClient.shared) {
        self.email = email
        self.api = api
    }

    var canVerify: Bool {
        code.count == 6
    }

    func sendCode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let body = try JSONEncoder().encode(["email": email])
            let endpoint = Endpoint(path: "auth/send-verification", method: .post, body: body)
            let _: String = try await api.send(endpoint)
            codeSent = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func verifyCode() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            struct VerifyRequest: Encodable {
                let email: String
                let code: String
            }
            let request = VerifyRequest(email: email, code: code)
            let body = try JSONEncoder().encode(request)
            let endpoint = Endpoint(path: "auth/verify-email", method: .post, body: body)
            let _: String = try await api.send(endpoint)
            isVerified = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
