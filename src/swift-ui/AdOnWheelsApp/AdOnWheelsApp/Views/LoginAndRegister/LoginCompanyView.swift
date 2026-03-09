import SwiftUI

struct LoginCompanyView: View {
    @StateObject private var viewModel = LoginCompanyViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
    var lockedRole: InitialUserRole? = nil
    var onBack: (() -> Void)? = nil
    @State private var isPasswordVisible: Bool = false

    var body: some View {
        AuthScaffold(
            headerMode: .login(role: "Company"),
            subtitle: "Login to your Company Account",
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
                GoogleSignInSection(authService: authService, role: "COMPANY")

                Button("Don't have an account? Register here") {
                    navViewModel.currentScreen = .registerCompany
                }
                .foregroundColor(.primary)
                .font(.callout)
            }
        )
    }
}

#Preview {
    let auth = AuthenticationService()
    let nav = AuthNavigationViewModel()
    nav.currentScreen = .loginCompany
    return LoginCompanyView(authService: auth, navViewModel: nav, lockedRole: nil, onBack: nil)
}
