import SwiftUI
import Combine
import CoreLocation

@MainActor
class RideViewModel: NSObject, ObservableObject {

    private let historyService = RideHistoryService.shared

    // MARK: - Published state

    @Published var isRiding: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distanceTravelled: Double = 0.0
    @Published var currentSpeed: Double = 0.0
    @Published var currentRideId: String?
    @Published var currentRide: Ride?           // retained for view compatibility
    @Published var lastCompletedRide: Ride?     // retained for view compatibility
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var activeCampaignName: String = "Active Campaign"

    // MARK: - Private state

    private var elapsedTimer: AnyCancellable?
    private var trackTimer: AnyCancellable?
    private var rideStartDate: Date?
    private var speedReadings: [Double] = []

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    // MARK: - Init

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Permission

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Ride lifecycle

    func startRide(campaignId: Int? = nil) async {
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let body = try JSONEncoder().encode(StartRideRequest(driverId: String(driverId)))
            let endpoint = Endpoint(path: "api/rides/start", method: .post, body: body)
            let response: StartRideResponse = try await api.send(endpoint)

            currentRideId = response.rideId
            rideStartDate = Date()
            isRiding = true
            elapsedTime = 0
            distanceTravelled = 0.0
            currentSpeed = 0.0
            speedReadings = []

            startElapsedTimer()
            startLocationTracking()

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

        stopLocationTracking()
        stopElapsedTimer()

        do {
            let body = try JSONEncoder().encode(EndRideRequest(rideId: rideId))
            let endpoint = Endpoint(path: "api/rides/end", method: .post, body: body)
            let response: EndRideResponse = try await api.send(endpoint)

            distanceTravelled = response.totalDistanceKm
            elapsedTime = TimeInterval(response.durationSeconds)

            saveRideToHistory(from: response)

            isRiding = false
            currentRideId = nil

            // Notify StatsViewModel to refresh after ride is saved
            NotificationCenter.default.post(name: .rideCompleted, object: nil)

        } catch {
            errorMessage = error.localizedDescription
            isRiding = false
            currentRideId = nil
        }

        isLoading = false
    }

    // MARK: - GPS tracking (fire-and-forget)

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

    // MARK: - Location tracking

    private func startLocationTracking() {
        locationManager.startUpdatingLocation()
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

    private func stopLocationTracking() {
        trackTimer?.cancel()
        trackTimer = nil
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Computed helpers

    var timeString: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }

    var averageSpeedKmh: Double {
        speedReadings.isEmpty ? 0 : speedReadings.reduce(0, +) / Double(speedReadings.count)
    }

    // MARK: - History

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

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        let speedKmh = max(0, location.speed * 3.6)
        Task { @MainActor [weak self] in
            self?.lastLocation = location
            self?.currentSpeed = speedKmh
            self?.speedReadings.append(speedKmh)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Location errors during a ride are non-fatal; tracking continues on next update
    }
}

// MARK: - Notification names

extension Notification.Name {
    static let rideCompleted = Notification.Name("rideCompleted")
}
