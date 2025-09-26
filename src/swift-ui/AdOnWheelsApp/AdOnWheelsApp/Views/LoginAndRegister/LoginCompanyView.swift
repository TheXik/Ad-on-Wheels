import SwiftUI

struct LoginCompanyView: View {
    @StateObject private var viewModel = LoginCompanyViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
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
            fields: {
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .authFieldStyle()

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $viewModel.password)
                    } else {
                        SecureField("Password", text: $viewModel.password)
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
            },
            bottomLinks: {
                Button("Don't have an account? Register here") {
                    navViewModel.currentScreen = .registerCompany
                }
                .foregroundColor(.primary)
                .font(.callout)

                Button("Are you a driver? Login here") {
                    navViewModel.currentScreen = .loginDriver
                }
                .foregroundColor(.primary.opacity(0.7))
                .font(.callout)
            }
        )
    }
}

#Preview {
    let auth = AuthenticationService()
    let nav = AuthNavigationViewModel()
    nav.currentScreen = .loginCompany
    return LoginCompanyView(authService: auth, navViewModel: nav)
}
