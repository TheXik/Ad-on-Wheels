import SwiftUI

struct RegisterCompanyView: View {
    @StateObject private var viewModel = RegisterCompanyViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Company Registration")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            TextField("Company name", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.organizationName)

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
                Text("Registration Successful! Please log in.")
                    .foregroundColor(.green)
                    .padding()
                Button("Back to Login") {
                    navViewModel.currentScreen = .loginCompany
                }
            }
            
            Spacer()

            Button("Already have an account ? Log in here") {
                navViewModel.currentScreen = .loginCompany  
            }
            Button("Are you a driver? Register here")
            {
                navViewModel.currentScreen = .registerDriver
            }
            .padding(.top, 10)
        }
        .padding(30)
        .navigationTitle("Company registration")
    }
}
