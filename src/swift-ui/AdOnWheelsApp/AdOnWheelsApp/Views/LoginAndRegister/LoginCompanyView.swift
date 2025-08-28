import SwiftUI

struct LoginCompanyView: View {
    @StateObject private var viewModel = LoginCompanyViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel


    var body: some View {
        VStack(spacing: 15) {
            Text("Login as a Company")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)

            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else {
                Button("Login") {
                    Task {
                        if await viewModel.login() {
                            authService.didLogin()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button("Don't have an account? Register here") {
                navViewModel.currentScreen = .registerCompany
            }
                        
            Button("Are you a driver? Login here") {
                navViewModel.currentScreen = .loginDriver
            }
            .padding(.top, 10)
            }
        .padding(30)
    }
}
