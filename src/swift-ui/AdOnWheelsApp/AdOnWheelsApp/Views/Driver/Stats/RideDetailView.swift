import SwiftUI
import MapKit
import CoreLocation

struct RideDetailView: View {
    let ride: Ride

    @State private var cameraPosition: MapCameraPosition
    @State private var startAddress: String?
    @State private var endAddress: String?

    init(ride: Ride) {
        self.ride = ride
        _cameraPosition = State(initialValue: Self.initialCamera(for: ride))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Map(position: $cameraPosition) {
                    if !ride.trackCoordinates.isEmpty {
                        MapPolyline(coordinates: ride.trackCoordinates)
                            .stroke(Color.blue, lineWidth: 5)
                    }
                    if let start = ride.startCoordinate {
                        Annotation("Start", coordinate: start) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 2)
                        }
                    }
                    if let end = ride.endCoordinate {
                        Annotation("End", coordinate: end) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 2)
                        }
                    }
                }
                .frame(height: 300)
                .edgesIgnoringSafeArea(.top)

                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(formattedDate)
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(statusText)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(statusColor)
                        }
                        Spacer()
                        Text(ride.formattedEarnings)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 20)

                    Divider()

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        DetailStatBox(title: "Distance", value: ride.formattedDistance)
                        DetailStatBox(title: "Duration", value: ride.formattedDuration)
                        DetailStatBox(title: "Avg Speed", value: String(format: "%.0f km/h", ride.averageSpeedKmh ?? 0))
                    }

                    NavigationLink(destination: RideMapView(rideId: ride.id)) {
                        HStack(spacing: 8) {
                            Image(systemName: "map")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Open full coverage map")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(10)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 15) {
                        Text("Route Info")
                            .font(.headline)

                        HStack {
                            Circle().fill(Color.green).frame(width: 10, height: 10)
                            Text("\(formattedStartTime) Start")
                                .font(.subheadline)
                        }

                        Text(startAddress ?? coordinateFallback(lat: ride.startLat, lon: ride.startLon))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading, 14)

                        HStack {
                            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 2, height: 20).padding(.leading, 4)
                        }

                        HStack {
                            Circle().fill(Color.red).frame(width: 10, height: 10)
                            Text("\(formattedEndTime) End")
                                .font(.subheadline)
                        }

                        Text(endAddress ?? coordinateFallback(lat: ride.endLat, lon: ride.endLon))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading, 14)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                }
                .padding()
            }
        }
        .navigationBarTitle(ride.displayTitle, displayMode: .inline)
        .task {
            await resolveAddresses()
        }
    }

    private var statusText: String {
        switch ride.status {
        case "ACTIVE": return "In Progress"
        case "COMPLETED": return "Completed"
        case "VERIFIED": return "Verified"
        case "CANCELLED": return "Cancelled"
        default: return ride.status
        }
    }

    private var statusColor: Color {
        switch ride.status {
        case "ACTIVE": return .blue
        case "COMPLETED": return .green
        case "VERIFIED": return .purple
        case "CANCELLED": return .red
        default: return .gray
        }
    }

    private var formattedDate: String {
        guard let date = Self.parseBackendDate(ride.startTime) else {
            return ride.startTime
        }
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "en_GB")
        displayFormatter.dateFormat = "dd.MM.yyyy"
        return displayFormatter.string(from: date)
    }

    private var formattedStartTime: String {
        guard let date = Self.parseBackendDate(ride.startTime) else { return "--:--" }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        return displayFormatter.string(from: date)
    }

    private var formattedEndTime: String {
        guard let endTime = ride.endTime,
              let date = Self.parseBackendDate(endTime) else { return "--:--" }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        return displayFormatter.string(from: date)
    }

    private static func parseBackendDate(_ value: String) -> Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: value) { return date }
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: value) { return date }

        // Backend sends LocalDateTime without a timezone designator but the
        // server writes UTC wall-clock, so we must parse as UTC and let the
        // display formatters convert to the user's local zone.
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        let fallback = DateFormatter()
        fallback.locale = Locale(identifier: "en_US_POSIX")
        fallback.timeZone = TimeZone(identifier: "UTC")
        for format in formats {
            fallback.dateFormat = format
            if let date = fallback.date(from: value) { return date }
        }
        return nil
    }

    private func coordinateFallback(lat: Double?, lon: Double?) -> String {
        guard let lat, let lon else { return "Location unavailable" }
        return String(format: "%.5f, %.5f", lat, lon)
    }

    private func resolveAddresses() async {
        if let start = ride.startCoordinate {
            startAddress = await reverseGeocode(coordinate: start)
        }
        if let end = ride.endCoordinate {
            endAddress = await reverseGeocode(coordinate: end)
        }
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        guard let placemark = try? await geocoder.reverseGeocodeLocation(location).first else {
            return nil
        }
        let parts = [
            placemark.thoroughfare,
            placemark.locality,
            placemark.country
        ].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    private static func initialCamera(for ride: Ride) -> MapCameraPosition {
        let coords = ride.trackCoordinates
        if !coords.isEmpty {
            let lats = coords.map { $0.latitude }
            let lons = coords.map { $0.longitude }
            let minLat = lats.min() ?? 0
            let maxLat = lats.max() ?? 0
            let minLon = lons.min() ?? 0
            let maxLon = lons.max() ?? 0
            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )
            let span = MKCoordinateSpan(
                latitudeDelta: max((maxLat - minLat) * 1.4, 0.005),
                longitudeDelta: max((maxLon - minLon) * 1.4, 0.005)
            )
            return .region(MKCoordinateRegion(center: center, span: span))
        }

        if let start = ride.startCoordinate {
            return .region(MKCoordinateRegion(
                center: start,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
        }

        return .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
}

struct DetailStatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct RideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RideDetailView(ride: Ride(
            id: 1,
            driverId: 1,
            campaignId: 1,
            startTime: "2024-01-15T10:00:00",
            endTime: "2024-01-15T11:00:00",
            duration: 3600,
            status: "COMPLETED",
            verified: true,
            distanceKm: 25.5,
            averageSpeedKmh: 45.0,
            earnings: 3.83,
            startLat: 50.0755,
            startLon: 14.4378,
            endLat: 50.0850,
            endLon: 14.4500,
            trackPoints: nil
        ))
    }
}
