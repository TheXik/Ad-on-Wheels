import Foundation
import CoreLocation

struct Ride: Identifiable, Codable {
    let id: Int
    let driverId: Int
    let campaignId: Int?
    let startTime: String
    let endTime: String?
    let duration: Int?          // Duration in seconds (matches backend field name)
    let status: String          // COMPLETED or DEFERRED (set by ride-service)
    let verified: Bool?         // Per-UC01 QR-scan verification flag

    let distanceKm: Double?
    let averageSpeedKmh: Double?
    let earnings: Double?

    let startLat: Double?
    let startLon: Double?
    let endLat: Double?
    let endLon: Double?
    let trackPoints: [LatLng]?

    struct LatLng: Codable, Hashable {
        let lat: Double
        let lon: Double
    }

    private static let pragueTimeZone = TimeZone(identifier: "Europe/Prague") ?? .current

    private var startDate: Date? {
        let withZ = startTime.contains("Z") || startTime.contains("+") ? startTime : startTime + "Z"
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = withFractional.date(from: withZ) { return d }
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: withZ)
    }

    var displayTitle: String {
        guard let date = startDate else { return "Ride" }
        let f = DateFormatter()
        f.timeZone = Self.pragueTimeZone
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "d.M.yyyy, HH:mm"
        return f.string(from: date)
    }

    var trackCoordinates: [CLLocationCoordinate2D] {
        (trackPoints ?? []).map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
    }

    var startCoordinate: CLLocationCoordinate2D? {
        guard let lat = startLat, let lon = startLon else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var endCoordinate: CLLocationCoordinate2D? {
        guard let lat = endLat, let lon = endLon else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var formattedDistance: String {
        guard let distance = distanceKm else { return "0 km" }
        return String(format: "%.1f km", distance)
    }

    var formattedEarnings: String {
        guard let earnings = earnings else { return "€0.00" }
        return String(format: "€%.2f", earnings)
    }

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
