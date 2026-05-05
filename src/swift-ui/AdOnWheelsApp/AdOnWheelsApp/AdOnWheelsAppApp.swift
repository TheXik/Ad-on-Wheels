import SwiftUI
import GoogleSignIn

enum InitialUserRole {
    case driver
    case company
    case none
}

@main
struct AdOnWheelsAppApp: App {
    @StateObject private var authService = AuthenticationService()
    @State private var selectedRole: InitialUserRole = .none
    @State private var showSplash = true
    @State private var showSessionExpiredToast = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    init() {
        let hasLaunchedKey = "hasLaunchedBefore"
        if !UserDefaults.standard.bool(forKey: hasLaunchedKey) {
            TokenManager.shared.deleteToken()
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if showSplash {
                        SplashScreenView {
                            showSplash = false
                        }
                        .transition(.opacity)
                    } else if authService.isAuthenticated {
                        switch authService.userRole {
                        case .driver:
                            DriverEntryView(authService: authService)
                        case .company:
                            CompanyRootView(authService: authService)
                        case .none:
                            AuthRouterView(authService: authService, initialScreen: nil)
                        }
                    } else {
                        if selectedRole == .none {
                            RoleSelectionView { chosenRole in
                                selectedRole = chosenRole
                            }
                        } else {
                            let initialScreen: AuthScreen = (selectedRole == .driver) ? .registerDriver : .registerCompany
                            AuthRouterView(
                                authService: authService,
                                initialScreen: initialScreen,
                                onBack: {
                                    selectedRole = .none
                                }
                            )
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showSplash)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onReceive(NotificationCenter.default.publisher(for: .authTokenExpired)) { _ in
                    // 401 from any APIClient call: sign the user out and surface a toast.
                    guard authService.isAuthenticated else { return }
                    authService.logout()
                    selectedRole = .none
                    withAnimation { showSessionExpiredToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { showSessionExpiredToast = false }
                    }
                }
                .preferredColorScheme(isDarkMode ? .dark : .light)

                if showSessionExpiredToast {
                    VStack {
                        Text("Session expired, please sign in again")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.85))
                            .cornerRadius(12)
                            .padding(.top, 60)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                }
            }
        }
    }
}
