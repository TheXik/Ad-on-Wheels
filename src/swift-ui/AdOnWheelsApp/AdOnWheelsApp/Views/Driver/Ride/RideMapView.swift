import SwiftUI
import MapKit
import CoreLocation

// Draws one completed ride's recorded GPS track as a MapPolyline,
// fitted to the route's bounding box with a small padding.
struct RideMapView: View {
    let rideId: Int

    @Environment(\.dismiss) private var dismiss
    @State private var coordinates: [CLLocationCoordinate2D] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition) {
                if !coordinates.isEmpty {
                    MapPolyline(coordinates: coordinates)
                        .stroke(Color.blue, lineWidth: 5)
                    if let start = coordinates.first {
                        Annotation("Start", coordinate: start) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 2)
                        }
                    }
                    if let end = coordinates.last {
                        Annotation("End", coordinate: end) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)

            if isLoading {
                ProgressView()
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 12)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 12)
            } else if coordinates.isEmpty {
                emptyBanner
            }
        }
        .navigationTitle("Route")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadRoute() }
    }

    private var emptyBanner: some View {
        VStack(spacing: 8) {
            Image(systemName: "map")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.6))
            Text("No GPS track recorded for this ride.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.top, 80)
    }

    private func loadRoute() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let endpoint = Endpoint(path: "api/rides/\(rideId)/route")
            let points: [RoutePoint] = try await APIClient.shared.send(endpoint)
            coordinates = points.map {
                CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
            }
            recenterCamera()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func recenterCamera() {
        guard !coordinates.isEmpty else { return }
        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }
        let minLat = lats.min() ?? 0
        let maxLat = lats.max() ?? 0
        let minLon = lons.min() ?? 0
        let maxLon = lons.max() ?? 0
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let latDelta = max((maxLat - minLat) * 1.1, 0.005)
        let lonDelta = max((maxLon - minLon) * 1.1, 0.005)
        cameraPosition = .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        ))
    }
}

private struct RoutePoint: Codable {
    let lat: Double
    let lon: Double
}
