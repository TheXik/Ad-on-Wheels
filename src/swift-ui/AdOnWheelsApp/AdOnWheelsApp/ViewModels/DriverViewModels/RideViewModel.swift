import SwiftUI
import Combine
import CoreLocation

@MainActor
class RideViewModel: NSObject, ObservableObject {

    private let historyService = RideHistoryService.shared

    @Published var isRiding: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distanceTravelled: Double = 0.0
    @Published var currentSpeed: Double = 0.0
    @Published var currentRideId: String?
    @Published var currentRide: Ride?
    @Published var lastCompletedRide: Ride?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locationVersion: Int = 0

    // MARK: - UC013 Deferred Ride Properties

    /// Whether background GPS buffering is active (always on when user has a campaign)
    @Published var isBufferingGPS: Bool = false

    /// Buffered GPS points collected in the background for deferred ride logging
    @Published private(set) var gpsBuffer: [DeferredLocationPoint] = []

    /// Whether a deferred ride was just completed
    @Published var deferredRideCompleted: Bool = false

    /// True if there are enough buffered points to reconstruct a ride
    var hasDeferredRideData: Bool { gpsBuffer.count >= 2 }

    var activeCampaignName: String = "Active Campaign"
    var activeCampaignId: Int?

    private var elapsedTimer: AnyCancellable?
    private var trackTimer: AnyCancellable?
    private var bufferTimer: AnyCancellable?
    private var speedStaleTimer: AnyCancellable?
    private var rideStartDate: Date?
    private var speedReadings: [Double] = []

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    /// ISO-8601 date formatter for deferred ride timestamps
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    #if DEBUG
    var isSimulatingMovement: Bool = false
    private var streetSimulator: StreetRouteSimulator?
    #endif

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Normal Ride Flow

    func startRide(campaignId: Int? = nil) async {
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }

        let cid = campaignId ?? activeCampaignId

        isLoading = true
        errorMessage = nil

        do {
            let body = try JSONEncoder().encode(StartRideRequest(driverId: String(driverId), campaignId: cid))
            let endpoint = Endpoint(path: "api/rides/start", method: .post, body: body)
            let response: StartRideResponse = try await api.send(endpoint)

            currentRideId = response.rideId
            rideStartDate = Date()
            isRiding = true
            elapsedTime = 0
            distanceTravelled = 0.0
            currentSpeed = 0.0
            speedReadings = []
            lastLocation = nil

            gpsBuffer = []
            stopGPSBuffering()

            locationManager.startUpdatingLocation()
            startElapsedTimer()
            startTrackTimer()
            startSpeedStaleTimer()

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func endRide() async {
        guard let rideId = currentRideId else {
            errorMessage = "No active ride"
            return
        }

        isLoading = true
        errorMessage = nil

        stopTrackTimer()
        stopElapsedTimer()
        stopSpeedStaleTimer()

        #if DEBUG
        stopSimulatedMovement()
        #endif

        do {
            let body = try JSONEncoder().encode(EndRideRequest(rideId: rideId))
            let endpoint = Endpoint(path: "api/rides/end", method: .post, body: body)
            let response: EndRideResponse = try await api.send(endpoint)

            distanceTravelled = response.totalDistanceKm
            elapsedTime = TimeInterval(response.durationSeconds)

            saveRideToHistory(from: response)

            isRiding = false
            currentRideId = nil

            // Resume GPS buffering after ride ends
            startGPSBuffering()

            NotificationCenter.default.post(name: .rideCompleted, object: nil)

        } catch {
            errorMessage = error.localizedDescription
            isRiding = false
            currentRideId = nil
        }

        isLoading = false
    }

    func trackPoint(lat: Double, lon: Double) {
        guard let rideId = currentRideId else { return }
        let api = self.api
        Task.detached {
            do {
                let body = try JSONEncoder().encode(TrackRequest(rideId: rideId, lat: lat, lon: lon))
                let endpoint = Endpoint(path: "api/rides/track", method: .post, body: body)
                try await api.send(endpoint)
            } catch {
                // fire-and-forget: errors are intentionally swallowed
            }
        }
    }

    // MARK: - UC013 Deferred Ride (Background GPS Buffering)

    /// Start buffering GPS points in the background.
    /// Called when the driver has an active campaign but hasn't started a ride.
    func startGPSBuffering() {
        guard !isRiding else { return }
        isBufferingGPS = true
        gpsBuffer = []

        // Buffer a GPS point every 10 seconds, but only if we actually moved
        bufferTimer = Timer.publish(every: 10.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let location = self.lastLocation else { return }

                // Skip if we haven't moved meaningfully since the last buffered point
                if let prev = self.gpsBuffer.last {
                    let prevLoc = CLLocation(latitude: prev.lat, longitude: prev.lon)
                    if location.distance(from: prevLoc) < Self.minDistanceMeters {
                        return
                    }
                }

                let point = DeferredLocationPoint(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude,
                    capturedAt: Self.isoFormatter.string(from: Date())
                )
                self.gpsBuffer.append(point)

                // Cap buffer at ~1 hour of data (360 points at 10s intervals)
                if self.gpsBuffer.count > 360 {
                    self.gpsBuffer.removeFirst()
                }
            }
    }

    /// Stop buffering GPS points
    func stopGPSBuffering() {
        bufferTimer?.cancel()
        bufferTimer = nil
        isBufferingGPS = false
    }

    /// UC013: Submit a deferred ride using the buffered GPS data.
    /// Called when the user scans QR at the end without having started a ride.
    func submitDeferredRide() async {
        guard hasDeferredRideData else {
            errorMessage = "Not enough GPS data to log a deferred ride"
            return
        }
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = DeferredRideRequest(
                driverId: String(driverId),
                campaignId: activeCampaignId,
                locationPoints: gpsBuffer
            )
            let body = try JSONEncoder().encode(request)
            let endpoint = Endpoint(path: "api/rides/deferred", method: .post, body: body)
            let response: EndRideResponse = try await api.send(endpoint)

            distanceTravelled = response.totalDistanceKm
            elapsedTime = TimeInterval(response.durationSeconds)

            saveRideToHistory(from: response)

            gpsBuffer = []
            deferredRideCompleted = true

            NotificationCenter.default.post(name: .rideCompleted, object: nil)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.deferredRideCompleted = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Timers

    private func startElapsedTimer() {
        elapsedTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] currentTime in
                guard let self, let start = self.rideStartDate else { return }
                self.elapsedTime = currentTime.timeIntervalSince(start)
            }
    }

    private func stopElapsedTimer() {
        elapsedTimer?.cancel()
        elapsedTimer = nil
    }

    private func startTrackTimer() {
        trackTimer = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let location = self.lastLocation else { return }
                self.trackPoint(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )
            }
    }

    private func stopTrackTimer() {
        trackTimer?.cancel()
        trackTimer = nil
    }

    private func startSpeedStaleTimer() {
        speedStaleTimer = Timer.publish(every: 3.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isRiding, let last = self.lastLocation else { return }
                if Date().timeIntervalSince(last.timestamp) > 3.0 {
                    self.currentSpeed = 0
                }
            }
    }

    private func stopSpeedStaleTimer() {
        speedStaleTimer?.cancel()
        speedStaleTimer = nil
    }

    var timeString: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }

    var averageSpeedKmh: Double {
        speedReadings.isEmpty ? 0 : speedReadings.reduce(0, +) / Double(speedReadings.count)
    }

    private func saveRideToHistory(from response: EndRideResponse) {
        let endDate = Date()
        let startDate = rideStartDate ?? endDate.addingTimeInterval(-Double(response.durationSeconds))

        let record = RideRecord(
            startTime: startDate,
            endTime: endDate,
            distance: response.totalDistanceKm,
            duration: TimeInterval(response.durationSeconds),
            averageSpeed: averageSpeedKmh,
            campaignName: activeCampaignName
        )

        historyService.addRide(record)
    }
}

// MARK: - CLLocationManagerDelegate

extension RideViewModel: CLLocationManagerDelegate {

    private static let minDistanceMeters: Double = 10
    private static let maxPlausibleSpeedKmh: Double = 200

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        // Reject inaccurate GPS readings (common indoors or with weak signal)
        guard location.horizontalAccuracy >= 0,
              location.horizontalAccuracy <= 20 else { return }

        Task { @MainActor [weak self] in
            guard let self else { return }
            #if DEBUG
            if self.isSimulatingMovement { return }
            #endif

            // Always update the map pin
            self.currentLocation = location.coordinate
            self.locationVersion += 1

            if let last = self.lastLocation {
                let dist = location.distance(from: last)
                let dt = location.timestamp.timeIntervalSince(last.timestamp)
                let impliedSpeedKmh = dt > 0 ? (dist / dt) * 3.6 : 0

                let isRealMovement = dist >= Self.minDistanceMeters
                                  && impliedSpeedKmh < Self.maxPlausibleSpeedKmh

                if isRealMovement {
                    if self.isRiding {
                        self.distanceTravelled += dist / 1000.0
                    }
                    self.currentSpeed = location.speed >= 0 ? location.speed * 3.6 : impliedSpeedKmh
                    self.speedReadings.append(self.currentSpeed)
                    self.lastLocation = location
                } else {
                    // Standing still or GPS jitter — zero out speed
                    self.currentSpeed = 0
                }
            } else {
                // First reading ever — just anchor, no distance/speed yet
                self.lastLocation = location
                self.currentSpeed = 0
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Location errors during a ride are non-fatal; tracking continues on next update
    }
}

#if DEBUG
extension RideViewModel {

    func startSimulatedMovement() {
        isSimulatingMovement = true
        locationManager.stopUpdatingLocation()
        distanceTravelled = 0.0

        let simulator = StreetRouteSimulator()
        self.streetSimulator = simulator

        simulator.onLocationUpdate = { [weak self] location in
            guard let self else { return }

            if self.isRiding, let last = self.lastLocation {
                self.distanceTravelled += location.distance(from: last) / 1000.0
            }

            self.lastLocation = location
            self.currentLocation = location.coordinate
            self.currentSpeed = max(0, location.speed * 3.6)
            self.speedReadings.append(self.currentSpeed)
            self.locationVersion += 1
        }

        let startCoord = currentLocation ?? StreetRouteSimulator.defaultStart
        lastLocation = CLLocation(latitude: startCoord.latitude, longitude: startCoord.longitude)
        currentLocation = startCoord
        locationVersion += 1

        simulator.start(from: startCoord)
    }

    func stopSimulatedMovement() {
        streetSimulator?.stop()
        streetSimulator = nil
        isSimulatingMovement = false
        locationManager.startUpdatingLocation()
    }
}
#endif

extension Notification.Name {
    static let rideCompleted = Notification.Name("rideCompleted")
}
