import SwiftUI

@main
struct AdOnWheelsAppApp: App {
    @StateObject private var authService = AuthenticationService()

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                switch authService.userRole {
                case .driver:
                    DriverHomePageView(authService: authService)
                case .company:
                    CompanyHomePageView(authService: authService)
                case .none:
                    AuthRouterView(authService: authService)
                }
            } else {
                AuthRouterView(authService: authService)
            }
        }
    }
}
