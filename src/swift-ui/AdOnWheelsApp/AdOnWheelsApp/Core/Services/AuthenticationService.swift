import Foundation

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userRole: UserRole?

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        guard let token = TokenManager.shared.retrieveToken() else {
            logout()
            return
        }

        guard let payload = decode(jwtToken: token) else {
            logout()
            return
        }

        if let exp = payload["exp"] as? Double {
            if Date().timeIntervalSince1970 >= exp {
                logout()
                return
            }
        } else if let exp = payload["exp"] as? Int {
            if Int(Date().timeIntervalSince1970) >= exp {
                logout()
                return
            }
        }

        if let roleString = payload["role"] as? String,
           let role = parseRole(from: roleString) {
            self.userRole = role
            self.isAuthenticated = true
        } else {
            logout()
        }
    }

    func didLogin(token: String) {
        do {
            try TokenManager.shared.save(token: token)
            checkAuthentication()
        } catch {
            logout()
        }
    }

    func logout() {
        TokenManager.shared.deleteToken()
        isAuthenticated = false
        userRole = nil
    }

    private func decode(jwtToken jwt: String) -> [String: Any]? {
        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }
        return decodeJWTPart(segments[1])
    }

    private func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 += padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    
    // TODO: Verify JWT signature and claims using your servers public key

    private func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
              let payload = json as? [String: Any] else {
            return nil
        }
        return payload
    }

    private func parseRole(from raw: String) -> UserRole? {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case "driver": return .driver
        case "company": return .company
        default: return nil
        }
    }
}
