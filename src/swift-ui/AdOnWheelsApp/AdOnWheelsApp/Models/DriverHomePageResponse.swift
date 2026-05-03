import Foundation

struct DriverHomePageResponse: Codable {
    let driver: Driver
    let statistics: RideStatistics?
}
