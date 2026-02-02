import Foundation

struct Driver: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
    
    // Vehicle info
    let vehicleMake: String?
    let vehicleModel: String?
    let vehicleYear: Int?
    let vehiclePlate: String?
    let vehicleColor: String?
    let vehicleVerified: Bool?
    
    // Driver info
    let rating: Double?
    let memberSince: String?
    
    // Computed properties
    var vehicleDisplayName: String {
        guard let make = vehicleMake, let model = vehicleModel else {
            return "No vehicle"
        }
        if let year = vehicleYear {
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
}


