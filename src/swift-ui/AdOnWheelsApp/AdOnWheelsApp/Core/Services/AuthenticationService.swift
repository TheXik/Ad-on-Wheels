
import Foundation

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        if TokenManager.shared.retrieveToken() != nil {
            isAuthenticated = true
        }
    }

    func logout() {
        TokenManager.shared.deleteToken()
        isAuthenticated = false
    }
    
    // Túto metódu zavoláme po úspešnom prihlásení
    func didLogin() {
        self.isAuthenticated = true
    }
}
