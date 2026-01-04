import Foundation

class AuthNavigationViewModel: ObservableObject {
    @Published var currentScreen: AuthScreen

    init(initialScreen: AuthScreen = .loginDriver) {
        self.currentScreen = initialScreen
    }
}
