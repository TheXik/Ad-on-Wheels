import SwiftUI

struct AuthRouterView: View {
    @StateObject private var navViewModel = AuthNavigationViewModel()
    @ObservedObject var authService: AuthenticationService

    var body: some View {
        VStack {
            switch navViewModel.currentScreen {
            case .loginDriver:
                LoginDriverView(authService: authService, navViewModel: navViewModel)
            case .loginCompany:
                LoginCompanyView(authService: authService, navViewModel: navViewModel)
            case .registerDriver:
                RegisterDriverView(authService: authService, navViewModel: navViewModel)
            case .registerCompany:
                RegisterCompanyView(authService: authService, navViewModel: navViewModel)
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        .animation(.default, value: navViewModel.currentScreen)
    }
}
