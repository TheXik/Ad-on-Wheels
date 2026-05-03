import Foundation

struct Application: Identifiable, Codable {
    let id: Int
    let campaignId: Int
    let driverId: Int
    let status: String
}

struct ApplicationWithDriver: Identifiable, Codable {
    let id: Int
    let campaignId: Int
    let campaignName: String
    let status: String
    let driver: Driver
}

struct ApplicationWithCampaign: Identifiable, Codable {
    let id: Int
    let campaignId: Int
    let campaignName: String
    let companyId: Int?
    let status: String
}

struct CampaignRideStat: Codable, Identifiable {
    var id: Int { campaign.id }
    let campaign: Campaign
    let rideStats: RideStatsData
}

struct RideStatsData: Codable {
    let totalRides: Int
    let totalDistanceKm: Double
    let totalEarnings: Double
}
