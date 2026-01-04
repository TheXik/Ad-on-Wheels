import SwiftUI

struct AuthRouterView: View {
    @StateObject private var navViewModel: AuthNavigationViewModel
    @ObservedObject var authService: AuthenticationService
    var initialScreen: AuthScreen? = nil
    var lockedRole: InitialUserRole? = nil
    var onBack: (() -> Void)? = nil
    @State private var didApplyInitialScreen = false

    init(authService: AuthenticationService, initialScreen: AuthScreen? = nil, lockedRole: InitialUserRole? = nil, onBack: (() -> Void)? = nil) {
        self._navViewModel = StateObject(wrappedValue: AuthNavigationViewModel())
        self.authService = authService
        self.initialScreen = initialScreen
        self.lockedRole = lockedRole
        self.onBack = onBack
    }

    var body: some View {
        Group {
            switch navViewModel.currentScreen {
            case .loginDriver:
                LoginDriverView(authService: authService, navViewModel: navViewModel, lockedRole: lockedRole, onBack: onBack)
            case .loginCompany:
                LoginCompanyView(authService: authService, navViewModel: navViewModel, lockedRole: lockedRole, onBack: onBack)
            case .registerDriver:
                RegisterDriverView(authService: authService, navViewModel: navViewModel, lockedRole: lockedRole, onBack: onBack)
            case .registerCompany:
                RegisterCompanyView(authService: authService, navViewModel: navViewModel, lockedRole: lockedRole, onBack: onBack)
            }
        }
        .onAppear {
            if !didApplyInitialScreen, let initialScreen = initialScreen {
                navViewModel.currentScreen = initialScreen
                didApplyInitialScreen = true
            }
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        .animation(.default, value: navViewModel.currentScreen)
    }
}
