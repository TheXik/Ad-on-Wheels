import Foundation

struct RideStatistics: Codable {
    let totalRides: Int
    let completedRides: Int
    let verifiedRides: Int
    let totalDurationSeconds: Int
    let averageDurationSeconds: Int
    let activeRidesCount: Int
    
    // New fields for distance and earnings
    let totalDistanceKm: Double?
    let weeklyDistanceKm: Double?
    let monthlyDistanceKm: Double?
    let totalEarnings: Double?
    let weeklyEarnings: Double?
    let monthlyEarnings: Double?
    let averageSpeedKmh: Double?
    let rating: Double?
    
    // Formatted computed properties
    var formattedTotalDistance: String {
        guard let distance = totalDistanceKm else { return "0 km" }
        return String(format: "%.1f km", distance)
    }
    
    var formattedWeeklyDistance: String {
        guard let distance = weeklyDistanceKm else { return "0 km" }
        return String(format: "%.1f km", distance)
    }
    
    var formattedMonthlyDistance: String {
        guard let distance = monthlyDistanceKm else { return "0 km" }
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
    
    var formattedRating: String {
        guard let rating = rating else { return "N/A" }
        return String(format: "%.1f", rating)
    }
    
    var formattedTotalDuration: String {
        let hours = totalDurationSeconds / 3600
        let minutes = (totalDurationSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
