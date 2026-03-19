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
