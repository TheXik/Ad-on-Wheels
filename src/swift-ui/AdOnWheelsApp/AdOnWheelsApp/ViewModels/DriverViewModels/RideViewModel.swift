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

    var activeCampaignName: String = "Active Campaign"

    private var elapsedTimer: AnyCancellable?
    private var trackTimer: AnyCancellable?
    private var rideStartDate: Date?
    private var speedReadings: [Double] = []

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    #if DEBUG
    var simulationTimer: AnyCancellable?
    var simulationIndex: Int = 0
    #endif

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
            lastLocation = nil

            startElapsedTimer()
            startTrackTimer()

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
            guard let self else { return }
            if self.isRiding, let last = self.lastLocation {
                self.distanceTravelled += location.distance(from: last) / 1000.0
            }
            self.lastLocation = location
            self.currentLocation = location.coordinate
            self.currentSpeed = speedKmh
            self.speedReadings.append(speedKmh)
            self.locationVersion += 1
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

    // Route through Bratislava city centre for testing
    static let simulatedRoute: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 48.14389, longitude: 17.10969),
        CLLocationCoordinate2D(latitude: 48.14492, longitude: 17.11123),
        CLLocationCoordinate2D(latitude: 48.14618, longitude: 17.11290),
        CLLocationCoordinate2D(latitude: 48.14731, longitude: 17.11422),
        CLLocationCoordinate2D(latitude: 48.14862, longitude: 17.11551),
        CLLocationCoordinate2D(latitude: 48.14995, longitude: 17.11678),
        CLLocationCoordinate2D(latitude: 48.15121, longitude: 17.11812),
        CLLocationCoordinate2D(latitude: 48.15253, longitude: 17.11942),
        CLLocationCoordinate2D(latitude: 48.15382, longitude: 17.12078),
        CLLocationCoordinate2D(latitude: 48.15501, longitude: 17.12207),
        CLLocationCoordinate2D(latitude: 48.15612, longitude: 17.12335),
        CLLocationCoordinate2D(latitude: 48.15731, longitude: 17.12461),
        CLLocationCoordinate2D(latitude: 48.15858, longitude: 17.12590),
        CLLocationCoordinate2D(latitude: 48.15963, longitude: 17.12715),
        CLLocationCoordinate2D(latitude: 48.16072, longitude: 17.12841),
        CLLocationCoordinate2D(latitude: 48.16181, longitude: 17.12965),
    ]

    func startSimulatedMovement() {
        locationManager.stopUpdatingLocation() // Pause real GPS so it doesn't conflict
        simulationIndex = 0
        simulationTimer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let route = RideViewModel.simulatedRoute
                let coord = route[self.simulationIndex % route.count]

                let simLocation = CLLocation(
                    coordinate: coord,
                    altitude: 200,
                    horizontalAccuracy: 5,
                    verticalAccuracy: 5,
                    course: 45,
                    speed: 11.0,
                    timestamp: Date()
                )

                if self.isRiding, let last = self.lastLocation {
                    self.distanceTravelled += simLocation.distance(from: last) / 1000.0
                }

                self.lastLocation = simLocation
                self.currentLocation = coord
                self.currentSpeed = 40.0
                self.speedReadings.append(40.0)
                self.locationVersion += 1

                if self.isRiding {
                    self.trackPoint(lat: coord.latitude, lon: coord.longitude)
                }

                self.simulationIndex += 1
            }
    }

    func stopSimulatedMovement() {
        simulationTimer?.cancel()
        simulationTimer = nil
        locationManager.startUpdatingLocation() // Resume real GPS
    }
}
#endif

extension Notification.Name {
    static let rideCompleted = Notification.Name("rideCompleted")
}
