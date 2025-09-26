import Foundation
import Security

final class TokenManager {
    static let shared = TokenManager()
    private let service: String = {
        let base = Bundle.main.bundleIdentifier ?? "com.AdOnWheelsApp"
        return base + ".token"
    }()

    private init() {}

    func save(token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw NSError(domain: "TokenManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode token"])
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "user_token",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        // Replace any existing token.
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: "TokenManager", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to save token to Keychain"])
        }
    }

    func retrieveToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "user_token",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
            return String(data: retrievedData, encoding: .utf8)
        }
        return nil
    }

    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "user_token"
        ]
        SecItemDelete(query as CFDictionary)
    }
}
