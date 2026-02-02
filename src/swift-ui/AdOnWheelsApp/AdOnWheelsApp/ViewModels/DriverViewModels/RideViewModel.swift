import SwiftUI
import Combine

@MainActor
class RideViewModel: ObservableObject {
    @Published var isRiding: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distanceTravelled: Double = 0.0
    @Published var currentSpeed: Double = 0.0
    @Published var currentRide: Ride?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Timer
    private var timer: AnyCancellable?
    private var rideStartDate: Date?

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
    }

    func startRide(campaignId: Int? = nil) async {
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let requestBody = StartRideRequest(campaignId: campaignId)
            let bodyData = try JSONEncoder().encode(requestBody)

            let endpoint = Endpoint(
                path: "rides/\(driverId)/start",
                method: .post,
                body: bodyData
            )

            let ride: Ride = try await api.send(endpoint)
            currentRide = ride
            
            // Parse ISO8601 date, handling the format from Java LocalDateTime
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            rideStartDate = formatter.date(from: ride.startTime) ?? Date()

            isRiding = true
            elapsedTime = 0
            distanceTravelled = 0.0
            currentSpeed = 45.0 // Mock speed km/h

            startTimer()

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func endRide() async {
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let requestBody = StopRideRequest()
            let bodyData = try JSONEncoder().encode(requestBody)

            let endpoint = Endpoint(
                path: "rides/\(driverId)/stop",
                method: .post,
                body: bodyData
            )

            let ride: Ride = try await api.send(endpoint)
            currentRide = ride

            stopTimer()
            isRiding = false

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func startTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] currentTime in
                self?.updateRideMetrics(currentTime: currentTime)
            }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    private func updateRideMetrics(currentTime: Date) {
        if let startDate = rideStartDate {
            elapsedTime = currentTime.timeIntervalSince(startDate)
        } else {
            elapsedTime += 1
        }

        // Mock distance calculation: 45km/h = 0.0125 km/s
        distanceTravelled += 0.0125

        // Vary speed slightly for "realism"
        currentSpeed = 45.0 + Double.random(in: -2...2)
    }

    var timeString: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}
