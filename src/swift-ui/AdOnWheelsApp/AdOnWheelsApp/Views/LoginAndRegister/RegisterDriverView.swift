import SwiftUI

struct RegisterDriverView: View {
    @StateObject private var viewModel = RegisterDriverViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
    
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Driver Registration")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            TextField("Name and Surname", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.name)

            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.newPassword)
            
            if viewModel.isLoading {
                ProgressView().padding()
            } else {
                Button("Register") {
                    Task {
                        await viewModel.register()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .disabled(viewModel.registrationSuccessful)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            if viewModel.registrationSuccessful {
                Text("Registration successful! You can now log in.")
                    .foregroundColor(.green)
                    .padding()
                Button("Back to Login") {
                    navViewModel.currentScreen = .loginDriver
                }
            }
            
            Spacer()
            
            Button("Already have an account ? Log in here") {
                navViewModel.currentScreen = .loginDriver
            }
            Button("Are you a company? Register here")
            {
                navViewModel.currentScreen = .registerCompany
            }
            .padding(10)
        }
        .padding(30)
        .navigationTitle("Driver Registration")
    }
}
