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
    var isSimulatingMovement: Bool = false
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
            #if DEBUG
            if self.isSimulatingMovement { return }
            #endif
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

    // Relative offsets (~150m steps) applied to the user's current position
    private static let routeOffsets: [(dlat: Double, dlon: Double)] = [
        (0.00000, 0.00000),
        (0.00103, 0.00154),
        (0.00229, 0.00321),
        (0.00342, 0.00453),
        (0.00473, 0.00582),
        (0.00606, 0.00709),
        (0.00732, 0.00843),
        (0.00864, 0.00973),
        (0.00993, 0.01109),
        (0.01112, 0.01238),
        (0.01223, 0.01366),
        (0.01342, 0.01492),
        (0.01469, 0.01621),
        (0.01574, 0.01746),
        (0.01683, 0.01872),
        (0.01792, 0.01996),
    ]

    private func buildRoute(from origin: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        Self.routeOffsets.map {
            CLLocationCoordinate2D(latitude: origin.latitude + $0.dlat,
                                   longitude: origin.longitude + $0.dlon)
        }
    }

    func startSimulatedMovement() {
        isSimulatingMovement = true
        locationManager.stopUpdatingLocation()
        simulationIndex = 0
        distanceTravelled = 0.0

        let origin = currentLocation ?? locationManager.location?.coordinate
            ?? CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378) // Prague fallback
        let route = buildRoute(from: origin)

        lastLocation = CLLocation(latitude: route[0].latitude, longitude: route[0].longitude)
        currentLocation = route[0]
        locationVersion += 1

        simulationTimer = Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
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
        isSimulatingMovement = false
        locationManager.startUpdatingLocation()
    }
}
#endif

extension Notification.Name {
    static let rideCompleted = Notification.Name("rideCompleted")
}
