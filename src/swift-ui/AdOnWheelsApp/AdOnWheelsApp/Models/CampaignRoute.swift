import Foundation
import CoreLocation

struct CampaignRoute: Identifiable, Codable {
    let rideId: Int
    let driverId: Int
    let distanceKm: Double?
    let status: String?
    let verified: Bool?
    let trackPoints: [Ride.LatLng]?

    var id: Int { rideId }

    var coordinates: [CLLocationCoordinate2D] {
        (trackPoints ?? []).map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
    }
}
