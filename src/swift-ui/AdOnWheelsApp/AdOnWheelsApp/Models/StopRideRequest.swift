import Foundation

struct StopRideRequest: Codable {
    let endLocation: String?
    let distanceKm: Double?
    let averageSpeedKmh: Double?
    
    init(endLocation: String? = nil, distanceKm: Double? = nil, averageSpeedKmh: Double? = nil) {
        self.endLocation = endLocation
        self.distanceKm = distanceKm
        self.averageSpeedKmh = averageSpeedKmh
    }
}
