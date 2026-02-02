import Foundation

struct StopRideRequest: Codable {
    let endLocation: String?
    
    init(endLocation: String? = nil) {
        self.endLocation = endLocation
    }
}
