import SwiftUI

struct RegisterCompanyView: View {
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
    var lockedRole: InitialUserRole? = nil
    var onBack: (() -> Void)? = nil
    @State private var isPasswordVisible: Bool = false
    @StateObject private var viewModel: RegisterCompanyViewModel
    
    init(authService: AuthenticationService, navViewModel: AuthNavigationViewModel, lockedRole: InitialUserRole? = nil, onBack: (() -> Void)? = nil) {
        self.authService = authService
        self.navViewModel = navViewModel
        self.lockedRole = lockedRole
        self.onBack = onBack
        self._viewModel = StateObject(wrappedValue: RegisterCompanyViewModel(authService: authService))
    }

    var body: some View {
        ZStack {
            AuthScaffold(
                headerMode: .register(role: "Company"),
                subtitle: "Create your Company Account",
                isLoading: viewModel.isLoading,
                errorMessage: viewModel.errorMessage,
                primaryButtonTitle: "Register",
                primaryAction: {
                    Task { await viewModel.register() }
                },
                onBack: onBack,
                fields: {
                    TextField("Company name", text: $viewModel.name, prompt: Text("Company name").foregroundColor(Color("BrandColor")))
                        .textContentType(.organizationName)
                        .foregroundColor(.primary)
                        .authFieldStyle()
                    if let error = viewModel.fieldErrors["name"] {
                        Text(error).foregroundColor(.red).font(.caption).padding(.horizontal)
                    }

                    TextField("Email", text: $viewModel.email, prompt: Text("Email").foregroundColor(Color("BrandColor")))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .foregroundColor(.primary)
                        .authFieldStyle()
                    if let error = viewModel.fieldErrors["email"] {
                        Text(error).foregroundColor(.red).font(.caption).padding(.horizontal)
                    } else if !viewModel.email.isEmpty && !viewModel.isEmailValid {
                        Text("Please enter a valid email address").foregroundColor(.red).font(.caption).padding(.horizontal)
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
                    .textContentType(.newPassword)
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
                    if !viewModel.registrationSuccessful {
                        GoogleSignInSection(authService: authService, role: "COMPANY")

                        Button("Already have an account? Log in here") {
                            navViewModel.currentScreen = .loginCompany
                        }
                        .foregroundColor(.primary)
                        .font(.callout)
                    }
                }
            )
            
            // Auto-navigate to home when registration is successful
            if viewModel.registrationSuccessful && authService.isAuthenticated {
                CompanyRootView(authService: authService)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

#Preview {
    let auth = AuthenticationService()
    let nav = AuthNavigationViewModel()
    nav.currentScreen = .registerCompany
    return RegisterCompanyView(authService: auth, navViewModel: nav, lockedRole: nil, onBack: nil)
}
