import Foundation

struct StartRideRequest: Codable {
    let campaignId: Int?
    let startLocation: String?
    
    init(campaignId: Int? = nil, startLocation: String? = nil) {
        self.campaignId = campaignId
        self.startLocation = startLocation
    }
}
