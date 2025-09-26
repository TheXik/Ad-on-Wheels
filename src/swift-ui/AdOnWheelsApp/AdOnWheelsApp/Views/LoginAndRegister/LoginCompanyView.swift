import SwiftUI

struct LoginCompanyView: View {
    @StateObject private var viewModel = LoginCompanyViewModel()
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
    @State private var isPasswordVisible: Bool = false


    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("BackgroundColor1").opacity(0.6), Color("BackgroundColor2").opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 5) {
                    Text("You are logging in as")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                        .shadow(radius: 5)
                        .padding(.top, 40)

                    Text("Company")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(Color("BrandColor"))
                        .shadow(radius: 5)
                        .shadow(color: Color("BrandColor").opacity(0.9), radius: 25, x: 0,y: 0)
                        .padding(.bottom,30)
                }
                
                Text("Login to your Company Account")
                    .font(.headline)
                    .foregroundColor(.primary.opacity(0.8))
                    .padding(.bottom, 30)

                // Input Fields
                VStack(spacing: 15) {
                    Group {
                        TextField("Email", text: $viewModel.email)
                            .padding()
                            .background(.primary.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.primary.opacity(0.8))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .accentColor(Color("BrandColor"))
                        HStack{
                            if isPasswordVisible{
                                TextField("Password",text:$viewModel.password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                            }
                        }
                        .padding()
                        .background(Color.primary.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.primary.opacity(0.8))
                        .textContentType(.password)
                        .accentColor(Color("BrandColor"))
                        .overlay(alignment: .trailing) {
                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(Color("BrandColor"))
                                }
                                .padding(.trailing, 10)
                            }
                            
                    }
                    
                }
                .padding(.horizontal)

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.vertical, 20)
                } else {
                    Button(action: {
                        Task {
                            if let token = await viewModel.login() {
                                authService.didLogin(token: token)
                            }
                        }
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("BrandColor"))
                            .cornerRadius(10)
                            .shadow(radius: 5)

                    }
                    .padding(.horizontal)
                }

                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                // Navigation Buttons
                VStack(spacing: 15) {
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
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    let auth = AuthenticationService()
    let nav = AuthNavigationViewModel()
    nav.currentScreen = .loginCompany
    return LoginCompanyView(authService: auth, navViewModel: nav)
}
