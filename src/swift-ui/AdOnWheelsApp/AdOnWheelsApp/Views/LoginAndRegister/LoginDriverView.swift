import SwiftUI

struct LoginDriverView: View {
    @StateObject private var viewModel = LoginDriverViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
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
                    navViewModel.currentScreen = .registerDriver
                }
                .foregroundColor(.primary)
                .font(.callout)

                Button("Are you a company? Login here") {
                    navViewModel.currentScreen = .loginCompany
                }
                .foregroundColor(.primary.opacity(0.7))
                .font(.callout)
            }
        )
    }
}
