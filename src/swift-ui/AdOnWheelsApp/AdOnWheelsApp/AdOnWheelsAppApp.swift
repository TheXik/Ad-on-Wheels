import SwiftUI

@main
struct AdOnWheelsAppApp: App {
    @StateObject private var authService = AuthenticationService()

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                HomePageView(authService: authService)
            } else {
                AuthRouterView(authService: authService)
            }
        }
    }
}
