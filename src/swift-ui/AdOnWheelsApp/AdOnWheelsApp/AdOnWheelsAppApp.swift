import SwiftUI

enum InitialUserRole {
    case driver
    case company
    case none
}

@main
struct AdOnWheelsAppApp: App {
    @StateObject private var authService = AuthenticationService()
    @State private var selectedRole: InitialUserRole = .none

    var body: some Scene {
        WindowGroup {
            // if the user is authenticated 
            if authService.isAuthenticated {
                switch authService.userRole {
                case .driver:
                    DriverRootView(authService: authService)
                case .company:
                    CompanyHomePageView(authService: authService)
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
    }
}
