import Foundation

struct RideStatistics: Codable {
    // Backend Long fields → Int64; backend Integer fields → Int.
    let totalRides: Int64
    let completedRides: Int64

    let totalDistanceKm: Double?
    let weeklyDistanceKm: Double?
    let monthlyDistanceKm: Double?
    let totalEarnings: Double?
    let weeklyEarnings: Double?
    let monthlyEarnings: Double?
    let averageSpeedKmh: Double?

    var formattedTotalDistance: String {
        guard let distance = totalDistanceKm else { return "0 km" }
        return String(format: "%.1f km", distance)
    }

    var formattedTotalEarnings: String {
        guard let earnings = totalEarnings else { return "€0.00" }
        return String(format: "€%.2f", earnings)
    }

    var formattedWeeklyEarnings: String {
        guard let earnings = weeklyEarnings else { return "€0.00" }
        return String(format: "€%.2f", earnings)
    }

    var formattedMonthlyEarnings: String {
        guard let earnings = monthlyEarnings else { return "€0.00" }
        return String(format: "€%.2f", earnings)
    }

    var formattedAverageSpeed: String {
        guard let speed = averageSpeedKmh else { return "0 km/h" }
        return String(format: "%.1f km/h", speed)
    }
}
