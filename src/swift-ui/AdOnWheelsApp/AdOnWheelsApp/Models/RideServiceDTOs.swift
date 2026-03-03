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
    let totalDistanceKm: Double
    let durationSeconds: Int
}
