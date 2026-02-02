import Foundation

struct DriverHomePageResponse: Codable {
    let driver: Driver
    let activeRide: Ride?
    let currentCampaign: Campaign?
    let statistics: RideStatistics?
}
