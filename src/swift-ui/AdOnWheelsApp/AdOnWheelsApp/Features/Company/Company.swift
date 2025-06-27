import Foundation

/// Represents a company entity in the Ad-on-Wheels app.
struct Company: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
} 