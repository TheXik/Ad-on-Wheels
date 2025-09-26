import SwiftUI

struct RegisterCompanyView: View {
    @StateObject private var viewModel = RegisterCompanyViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        AOWAuthScaffold(
            headerMode: .register(role: "Company"),
            subtitle: "Create your Company Account",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            primaryButtonTitle: "Register",
            primaryAction: {
                Task { await viewModel.register() }
            },
            fields: {
                TextField("Company name", text: $viewModel.name)
                    .textContentType(.organizationName)
                    .aowAuthFieldStyle()

                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .aowAuthFieldStyle()

                HStack {
                    if isPasswordVisible {
                        TextField("Password", text: $viewModel.password)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                    }
                }
                .textContentType(.newPassword)
                .aowAuthFieldStyle()
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
                if viewModel.registrationSuccessful {
                    Text("Registration Successful! Please log in.")
                        .foregroundColor(.green)

                    Button("Back to Login") {
                        navViewModel.currentScreen = .loginCompany
                    }
                    .foregroundColor(.primary)
                }

                Button("Already have an account? Log in here") {
                    navViewModel.currentScreen = .loginCompany
                }
                .foregroundColor(.primary)
                .font(.callout)

                Button("Are you a driver? Register here") {
                    navViewModel.currentScreen = .registerDriver
                }
                .foregroundColor(.primary.opacity(0.7))
                .font(.callout)
            }
        )
    }
}
