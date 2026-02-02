import Foundation

struct RideStatistics: Codable {
    let totalRides: Int
    let completedRides: Int
    let verifiedRides: Int
    let totalDurationSeconds: Int
    let averageDurationSeconds: Int
    let activeRidesCount: Int
}
