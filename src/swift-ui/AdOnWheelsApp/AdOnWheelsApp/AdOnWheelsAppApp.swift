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
                        AuthRouterView(authService: authService, initialScreen: nil, lockedRole: nil)
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
                            lockedRole: selectedRole,
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
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
