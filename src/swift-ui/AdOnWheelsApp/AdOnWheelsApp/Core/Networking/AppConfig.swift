import Foundation

enum AppConfig {
    static var baseURLString: String {
        if let configured = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !configured.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return configured
        }
        return LocalConfig.backendURL
    }

    static var baseURL: URL {
        let raw = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = raw.hasSuffix("/") ? String(raw.dropLast()) : raw
        guard let url = URL(string: normalized) else {
            preconditionFailure("Invalid base URL: \(baseURLString)")
        }
        return url
    }
}
