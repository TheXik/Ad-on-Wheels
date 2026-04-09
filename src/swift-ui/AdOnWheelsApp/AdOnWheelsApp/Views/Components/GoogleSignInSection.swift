import SwiftUI
import GoogleSignIn

struct GoogleSignInSection: View {
    let authService: AuthenticationService
    let role: String
    var onRoleMismatch: ((UserRole, String) -> Void)? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let googleClientID = "1009636850818-ju60fnmur0s7dvlr0qrp0cujl7u1l3e2.apps.googleusercontent.com"
    private let api: APIClientProtocol = APIClient.shared

    var body: some View {
        VStack(spacing: 16) {
            orDivider

            Button {
                Task { await signInWithGoogle() }
            } label: {
                HStack(spacing: 10) {
                    Image("GoogleLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.primary)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        .background(Color("FieldBgColor").cornerRadius(10))
                )
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.6 : 1)

            if isLoading {
                ProgressView()
                    .tint(Color("BrandColor"))
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.horizontal)
    }

    private var orDivider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.primary.opacity(0.2))
                .frame(height: 1)
            Text("or")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Rectangle()
                .fill(Color.primary.opacity(0.2))
                .frame(height: 1)
        }
    }

    private func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presenter = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to present Google Sign-In."
            return
        }

        var capturedIdToken: String?
        do {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: googleClientID)
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)

            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Google Sign-In did not return an ID token."
                return
            }
            capturedIdToken = idToken

            let requestBody: [String: String] = ["idToken": idToken, "role": role]
            let endpoint = Endpoint(
                path: "auth/google",
                method: .post,
                body: try JSONEncoder().encode(requestBody)
            )
            let response: LoginResponse = try await api.sendMapped(endpoint)
            authService.didLogin(token: response.token)
        } catch let error as GIDSignInError where error.code == .canceled {
            return
        } catch {
            let mapped = AppErrorMapper.map(error)
            if case .roleMismatch(let existing) = mapped, let idToken = capturedIdToken {
                onRoleMismatch?(existing, idToken)
            } else {
                errorMessage = mapped.errorDescription ?? error.localizedDescription
            }
        }
    }
}
