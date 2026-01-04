import SwiftUI

struct RegisterDriverView: View {
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var navViewModel: AuthNavigationViewModel
    var lockedRole: InitialUserRole? = nil
    var onBack: (() -> Void)? = nil
    @State private var isPasswordVisible: Bool = false
    
    @StateObject private var viewModel: RegisterDriverViewModel
    
    init(authService: AuthenticationService, navViewModel: AuthNavigationViewModel, lockedRole: InitialUserRole? = nil, onBack: (() -> Void)? = nil) {
        self.authService = authService
        self.navViewModel = navViewModel
        self.lockedRole = lockedRole
        self.onBack = onBack
        self._viewModel = StateObject(wrappedValue: RegisterDriverViewModel(authService: authService))
    }

    var body: some View {
        AuthScaffold(
            headerMode: .register(role: "Driver"),
            subtitle: "Create your Driver Account",
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            primaryButtonTitle: "Register",
            primaryAction: {
                Task { await viewModel.register() }
            },
            onBack: onBack,
            fields: {
                TextField("Name and Surname", text: $viewModel.name, prompt: Text("Name and Surname").foregroundColor(Color("BrandColor")))
                    .textContentType(.name)
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
                if viewModel.registrationSuccessful {
                    VStack(spacing: 10) {
                        Text("Registration successful!")
                            .foregroundColor(.green)
                            .font(.headline)
                        
                        Text("Please log in with your credentials.")
                            .foregroundColor(.primary.opacity(0.8))
                            .font(.callout)
                        
                        Button("Go to Login") {
                            navViewModel.currentScreen = .loginDriver
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("BrandColor"))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                } else {
                    Button("Already have an account? Log in here") {
                        navViewModel.currentScreen = .loginDriver
                    }
                    .foregroundColor(.primary)
                    .font(.callout)
                }
            }
        )
    }
}

#Preview {
    let auth = AuthenticationService()
    let nav = AuthNavigationViewModel()
    nav.currentScreen = .registerDriver
    return RegisterDriverView(authService: auth, navViewModel: nav, lockedRole: nil, onBack: nil)
}
