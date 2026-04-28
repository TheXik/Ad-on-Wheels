import Foundation

struct StartRideResponse: Decodable {
    let rideId: String
}

struct TrackRequest: Encodable {
    let rideId: String
    let lat: Double
    let lon: Double
}

struct EndRideResponse: Decodable {
    let completedRideId: Int64?
    let totalDistanceKm: Double
    let durationSeconds: Int
}

// MARK: - UC013 Deferred Ride DTOs

struct DeferredLocationPoint: Codable {
    let lat: Double
    let lon: Double
    let capturedAt: String // ISO-8601 timestamp
}

struct DeferredRideRequest: Encodable {
    let driverId: String
    let campaignId: Int?
    let ratePerKm: Double?
    let locationPoints: [DeferredLocationPoint]
}
