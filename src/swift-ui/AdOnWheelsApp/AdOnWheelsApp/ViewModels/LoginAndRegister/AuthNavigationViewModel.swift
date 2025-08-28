import Foundation

class AuthNavigationViewModel: ObservableObject {
    @Published var currentScreen: AuthScreen = .loginDriver
}
