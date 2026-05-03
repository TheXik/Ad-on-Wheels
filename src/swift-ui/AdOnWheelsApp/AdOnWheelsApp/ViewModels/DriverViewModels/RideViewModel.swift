import SwiftUI
import Combine
import CoreLocation

@MainActor
class RideViewModel: NSObject, ObservableObject {

    @Published var isRiding: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distanceTravelled: Double = 0.0
    @Published var currentSpeed: Double = 0.0
    @Published var currentRideId: String?
    @Published var lastCompletedRideId: Int64?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locationVersion: Int = 0

    @Published private(set) var gpsBuffer: [DeferredLocationPoint] = []
    var hasDeferredRideData: Bool { gpsBuffer.count >= 2 }

    var activeCampaignName: String = "Active Campaign"
    var activeCampaignId: Int?
    var activeCampaignRatePerKm: Double?

    private var elapsedTimer: AnyCancellable?
    private var trackTimer: AnyCancellable?
    private var bufferTimer: AnyCancellable?
    private var speedStaleTimer: AnyCancellable?
    private var rideStartDate: Date?

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    private let api: APIClientProtocol
    private let authService: AuthenticationService

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


    func startRide(campaignId: Int? = nil) async {
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }

        let cid = campaignId ?? activeCampaignId

        isLoading = true
        errorMessage = nil

        do {
            let body = try JSONEncoder().encode(StartRideRequest(driverId: String(driverId), campaignId: cid, ratePerKm: activeCampaignRatePerKm))
            let endpoint = Endpoint(path: "api/rides/start", method: .post, body: body)
            let response: StartRideResponse = try await api.send(endpoint)

            currentRideId = response.rideId
            rideStartDate = Date()
            isRiding = true
            elapsedTime = 0
            distanceTravelled = 0.0
            currentSpeed = 0.0
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
            lastCompletedRideId = response.completedRideId

            isRiding = false
            currentRideId = nil

            startGPSBuffering()

            NotificationCenter.default.post(name: .rideCompleted, object: nil)

        } catch {
            errorMessage = error.localizedDescription
            isRiding = false
            currentRideId = nil
        }

        isLoading = false
    }

    func verifyRide(completedRideId: Int64) async {
        do {
            let endpoint = Endpoint(path: "api/rides/\(completedRideId)/verify", method: .post, body: nil)
            try await api.send(endpoint)
        } catch {
            errorMessage = error.localizedDescription
        }
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
                // fire-and-forget
            }
        }
    }


    // Background GPS buffering for the deferred-QR case (driver only scans
    // at the end). One point every 10 s, capped at ~1 h.
    func startGPSBuffering() {
        guard !isRiding else { return }
        gpsBuffer = []

        bufferTimer = Timer.publish(every: 10.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let location = self.lastLocation else { return }

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

                if self.gpsBuffer.count > 360 {
                    self.gpsBuffer.removeFirst()
                }
            }
    }

    func stopGPSBuffering() {
        bufferTimer?.cancel()
        bufferTimer = nil
    }

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
                ratePerKm: activeCampaignRatePerKm,
                locationPoints: gpsBuffer
            )
            let body = try JSONEncoder().encode(request)
            let endpoint = Endpoint(path: "api/rides/deferred", method: .post, body: body)
            let response: EndRideResponse = try await api.send(endpoint)

            distanceTravelled = response.totalDistanceKm
            elapsedTime = TimeInterval(response.durationSeconds)

            gpsBuffer = []

            NotificationCenter.default.post(name: .rideCompleted, object: nil)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }


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

}


extension RideViewModel: CLLocationManagerDelegate {

    private static let minDistanceMeters: Double = 10
    private static let maxPlausibleSpeedKmh: Double = 200

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        // Drop bad GPS fixes (indoor / weak signal).
        guard location.horizontalAccuracy >= 0,
              location.horizontalAccuracy <= 20 else { return }

        Task { @MainActor [weak self] in
            guard let self else { return }
            #if DEBUG
            if self.isSimulatingMovement { return }
            #endif

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
                    self.lastLocation = location
                } else {
                    self.currentSpeed = 0
                }
            } else {
                self.lastLocation = location
                self.currentSpeed = 0
            }
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Non-fatal — tracking resumes on the next update.
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
