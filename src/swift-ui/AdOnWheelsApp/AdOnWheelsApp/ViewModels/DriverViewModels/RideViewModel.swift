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

    var activeCampaignName: String = "Active Campaign"

    private var elapsedTimer: AnyCancellable?
    private var trackTimer: AnyCancellable?
    private var rideStartDate: Date?
    private var speedReadings: [Double] = []

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

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

extension Notification.Name {
    static let rideCompleted = Notification.Name("rideCompleted")
}
