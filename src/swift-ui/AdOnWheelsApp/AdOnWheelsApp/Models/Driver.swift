import Foundation

struct Driver: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
    
    // Vehicle info
    let vehicleMake: String?
    let vehicleModel: String?
    let vehicleYear: String?
    let vehiclePlate: String?
    let vehicleColor: String?
    let vehicleImageUrl: String?
    let vehicleVerified: Bool?
    
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
    
    var isVehicleVerified: Bool {
        vehicleVerified ?? false
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


