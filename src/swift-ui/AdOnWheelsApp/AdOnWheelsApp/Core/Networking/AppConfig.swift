import Foundation

enum AppConfig {
    // This must be changed when going to production
    static let baseURLString: String = "http://192.168.0.120:8084"

    static var baseURL: URL {
        guard let url = URL(string: baseURLString) else {
            preconditionFailure("Invalid base URL: \(baseURLString)")
        }
        return url
    }
}
