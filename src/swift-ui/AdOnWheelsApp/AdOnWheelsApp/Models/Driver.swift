import Foundation

struct Driver: Identifiable, Codable {
    let id: Int
    let name: String

    // FR.6: make, model, year, license plate. FR.14: decal photo.
    let vehicleMake: String?
    let vehicleModel: String?
    let vehicleYear: String?
    let vehiclePlate: String?
    let vehicleImageUrl: String?

    let monthlyGoalKm: Double?
    let onboardingCompleted: Bool?
    let memberSince: String?

    var vehicleDisplayName: String {
        guard let make = vehicleMake, let model = vehicleModel else {
            return "No vehicle"
        }
        if let year = vehicleYear, !year.isEmpty {
            return "\(year) \(make) \(model)"
        }
        return "\(make) \(model)"
    }

    var needsOnboarding: Bool {
        !(onboardingCompleted ?? false) || vehicleMake == nil
    }

    var resolvedVehicleImageURL: URL? {
        guard let path = vehicleImageUrl, !path.isEmpty else { return nil }
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        var prefixed = path
        if prefixed.hasPrefix("/drivers/images/") {
            prefixed = "/api" + prefixed
        }
        let normalized = prefixed.hasPrefix("/") ? String(prefixed.dropFirst()) : prefixed
        return AppConfig.baseURL.appendingPathComponent(normalized)
    }
}


