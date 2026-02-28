import Foundation

struct Ride: Identifiable, Codable {
    let id: Int
    let driverId: Int
    let campaignId: Int?
    let startTime: String
    let endTime: String?
    let startLocation: String?
    let endLocation: String?
    let duration: Int?          // Duration in seconds (matches backend field name)
    let qrCodeData: String?
    let status: String          // ACTIVE, COMPLETED, VERIFIED, CANCELLED
    let campaignName: String?   // Campaign name for display
    
    // New fields for distance and earnings
    let distanceKm: Double?
    let averageSpeedKmh: Double?
    let earnings: Double?
    
    // Computed property for display
    var displayCampaignName: String {
        campaignName ?? "Campaign #\(campaignId ?? 0)"
    }
    
    // Computed property for formatted distance
    var formattedDistance: String {
        guard let distance = distanceKm else { return "0 km" }
        return String(format: "%.1f km", distance)
    }
    
    // Computed property for formatted earnings
    var formattedEarnings: String {
        guard let earnings = earnings else { return "€0.00" }
        return String(format: "€%.2f", earnings)
    }
    
    // Computed property for formatted duration
    var formattedDuration: String {
        guard let duration = duration else { return "0s" }
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = duration % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}
