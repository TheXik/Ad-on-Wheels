import SwiftUI

struct LoginDriverView: View {
    @StateObject private var viewModel = LoginDriverViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
    var lockedRole: InitialUserRole? = nil
    var onBack: (() -> Void)? = nil
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        AuthScaffold(
            headerMode: .login(role: "Driver"),
            subtitle: "Login to your Driver Account",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            primaryButtonTitle: "Login",
            primaryAction: {
                Task {
                    if let token = await viewModel.login() {
                        authService.didLogin(token: token)
                    }
                }
            },
            onBack: onBack,
            fields: {
                TextField("Email", text: $viewModel.email, prompt: Text("Email").foregroundColor(Color("BrandColor")))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .foregroundColor(.primary)
                    .authFieldStyle()
                if let error = viewModel.fieldErrors["email"] {
                    Text(error).foregroundColor(.red).font(.caption).padding(.horizontal)
                }

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $viewModel.password, prompt: Text("Password").foregroundColor(Color("BrandColor")))
                            .foregroundColor(.primary)
                    } else {
                        SecureField("Password", text: $viewModel.password, prompt: Text("Password").foregroundColor(Color("BrandColor")))
                            .foregroundColor(.primary)
                    }
                }
                .textContentType(.password)
                .authFieldStyle()
                .overlay(alignment: .trailing) {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(Color("BrandColor"))
                    }
                    .padding(.trailing, 10)
                }
                if let error = viewModel.fieldErrors["password"] {
                    Text(error).foregroundColor(.red).font(.caption).padding(.horizontal)
                }
            },
            bottomLinks: {
                GoogleSignInSection(
                    authService: authService,
                    role: "DRIVER",
                    onRoleMismatch: { existing, _ in
                        viewModel.roleMismatch = existing
                    }
                )

                Button("Don't have an account? Register here") {
                    navViewModel.currentScreen = .registerDriver
                }
                .foregroundColor(.primary)
                .font(.callout)
            }
        )
        .alert(
            "Account already exists",
            isPresented: Binding(
                get: { viewModel.roleMismatch != nil },
                set: { if !$0 { viewModel.roleMismatch = nil } }
            ),
            presenting: viewModel.roleMismatch
        ) { existing in
            Button("Cancel", role: .cancel) {
                viewModel.roleMismatch = nil
            }
            Button("Log in as \(existing.rawValue)") {
                viewModel.roleMismatch = nil
                Task {
                    if let token = await viewModel.loginAsExistingRole() {
                        authService.didLogin(token: token)
                    }
                }
            }
        } message: { existing in
            Text("This email is already registered as a \(existing.rawValue). Would you like to log in as a \(existing.rawValue) instead?")
        }
    }
}

#Preview {
    let auth = AuthenticationService()
    let nav = AuthNavigationViewModel()
    nav.currentScreen = .loginDriver
    return LoginDriverView(authService: auth, navViewModel: nav, lockedRole: nil, onBack: nil)
}
