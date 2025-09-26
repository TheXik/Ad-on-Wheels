import SwiftUI

struct RegisterDriverView: View {
    @StateObject private var viewModel = RegisterDriverViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        AOWAuthScaffold(
            headerMode: .register(role: "Driver"),
            subtitle: "Create your Driver Account",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            primaryButtonTitle: "Register",
            primaryAction: {
                Task { await viewModel.register() }
            },
            fields: {
                TextField("Name and Surname", text: $viewModel.name)
                    .textContentType(.name)
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
                    Text("Registration successful! You can now log in.")
                        .foregroundColor(.green)

                    Button("Back to Login") {
                        navViewModel.currentScreen = .loginDriver
                    }
                    .foregroundColor(.primary)
                }

                Button("Already have an account? Log in here") {
                    navViewModel.currentScreen = .loginDriver
                }
                .foregroundColor(.primary)
                .font(.callout)

                Button("Are you a company? Register here") {
                    navViewModel.currentScreen = .registerCompany
                }
                .foregroundColor(.primary.opacity(0.7))
                .font(.callout)
            }
        )
    }
}
