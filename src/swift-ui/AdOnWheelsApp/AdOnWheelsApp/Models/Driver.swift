import Foundation

struct Driver: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
    
    // Vehicle info (FR.6 — make, model, year, license plate; FR.14 — decal photo)
    let vehicleMake: String?
    let vehicleModel: String?
    let vehicleYear: String?
    let vehiclePlate: String?
    let vehicleImageUrl: String?
    
    // Driver info
    let rating: Double?
    let monthlyGoalKm: Double?
    let onboardingCompleted: Bool?
    let memberSince: String?
    
    // Computed properties
    var vehicleDisplayName: String {
        guard let make = vehicleMake, let model = vehicleModel else {
            return "No vehicle"
        }
        if let year = vehicleYear, !year.isEmpty {
            return "\(year) \(make) \(model)"
        }
        return "\(make) \(model)"
    }
    
    var formattedRating: String {
        guard let rating = rating else { return "N/A" }
        return String(format: "%.1f", rating)
    }
    
    var needsOnboarding: Bool {
        !(onboardingCompleted ?? false) && vehicleMake == nil
    }

    var resolvedVehicleImageURL: URL? {
        guard let path = vehicleImageUrl, !path.isEmpty else { return nil }
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        let normalized = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return AppConfig.baseURL.appendingPathComponent(normalized)
    }
}


