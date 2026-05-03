import SwiftUI
import MapKit

// One MapPolyline per completed ride for the campaign.
// Verified rides solid blue, unverified dashed grey.
struct CampaignCoverageView: View {
    let campaign: Campaign
    @Environment(\.dismiss) private var dismiss

    @State private var routes: [CoverageRoute] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Map(position: $cameraPosition) {
                    ForEach(routes) { route in
                        if !route.coordinates.isEmpty {
                            if route.verified {
                                MapPolyline(coordinates: route.coordinates)
                                    .stroke(Color.blue, lineWidth: 4)
                            } else {
                                MapPolyline(coordinates: route.coordinates)
                                    .stroke(
                                        Color.gray.opacity(0.7),
                                        style: StrokeStyle(lineWidth: 3, dash: [6, 4])
                                    )
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                summaryBar
                    .padding(.horizontal)
                    .padding(.top, 8)

                if isLoading {
                    ProgressView()
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                } else if let errorMessage {
                    errorBanner(errorMessage)
                } else if routes.isEmpty {
                    emptyBanner
                }
            }
            .navigationTitle("Coverage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task { await loadRoutes() }
        }
    }

    private var summaryBar: some View {
        HStack(spacing: 14) {
            summaryItem(title: "Rides", value: "\(routes.count)")
            Divider().frame(height: 28)
            summaryItem(title: "Verified", value: "\(verifiedCount) / \(routes.count)")
            Divider().frame(height: 28)
            legend
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func summaryItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundColor(.secondary)
            Text(value).font(.subheadline).fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Rectangle().fill(Color.blue).frame(width: 14, height: 3)
                Text("Verified").font(.caption2).foregroundColor(.secondary)
            }
            HStack(spacing: 6) {
                LegendDashLine().stroke(Color.gray.opacity(0.7),
                                       style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                    .frame(width: 14, height: 3)
                Text("Unverified").font(.caption2).foregroundColor(.secondary)
            }
        }
    }

    private var emptyBanner: some View {
        VStack(spacing: 8) {
            Image(systemName: "map")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.6))
            Text("No rides recorded yet for this campaign.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.top, 80)
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundColor(.red)
            .padding(10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .padding(.top, 80)
    }

    private var verifiedCount: Int {
        routes.filter { $0.verified }.count
    }

    private func loadRoutes() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let endpoint = Endpoint(path: "api/campaigns/\(campaign.id)/coverage")
            let coverage: CoverageResponse = try await APIClient.shared.send(endpoint)
            routes = coverage.routes ?? []
            recenterCamera()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func recenterCamera() {
        let allCoords = routes.flatMap { $0.coordinates }
        guard !allCoords.isEmpty else { return }
        let lats = allCoords.map { $0.latitude }
        let lons = allCoords.map { $0.longitude }
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


private struct CoverageResponse: Codable {
    let routes: [CoverageRoute]?
}

struct CoverageRoute: Identifiable, Codable {
    let rideId: Int
    let verified: Bool
    let route: [CoveragePoint]?

    var id: Int { rideId }

    var coordinates: [CLLocationCoordinate2D] {
        (route ?? []).map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
    }
}

struct CoveragePoint: Codable {
    let lat: Double
    let lon: Double
}

private struct LegendDashLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return p
    }
}
