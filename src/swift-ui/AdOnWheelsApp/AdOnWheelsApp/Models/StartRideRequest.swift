import Foundation

struct StartRideRequest: Encodable {
    let driverId: String
    let campaignId: Int?
}
