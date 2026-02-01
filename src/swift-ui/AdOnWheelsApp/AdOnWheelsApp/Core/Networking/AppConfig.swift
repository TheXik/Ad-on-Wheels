import Foundation

enum AppConfig {
    //TODO: when going to production remove this "http://192.168.1.27:8080" // desktop
    private static let defaultBaseURLString: String = "http://172.20.10.5:8080" // laptop


    
    static var baseURLString: String {
        if let configured = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           !configured.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return configured
        }
        return defaultBaseURLString
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
