import SwiftUI
import Combine

@MainActor
class RideViewModel: ObservableObject {
    private let historyService = RideHistoryService.shared
    @Published var isRiding: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distanceTravelled: Double = 0.0
    @Published var currentSpeed: Double = 0.0
    @Published var currentRide: Ride?
    @Published var lastCompletedRide: Ride?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Active campaign name for tracking
    var activeCampaignName: String = "Active Campaign"

    // Timer
    private var timer: AnyCancellable?
    private var rideStartDate: Date?
    
    // Track speeds for average calculation
    private var speedReadings: [Double] = []

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
            currentSpeed = 0.0
            speedReadings = []

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
            // Calculate average speed from readings
            let averageSpeed = speedReadings.isEmpty ? 0 : speedReadings.reduce(0, +) / Double(speedReadings.count)
            
            // Send distance and speed to backend
            let requestBody = StopRideRequest(
                endLocation: nil,
                distanceKm: distanceTravelled,
                averageSpeedKmh: averageSpeed
            )
            let bodyData = try JSONEncoder().encode(requestBody)

            let endpoint = Endpoint(
                path: "rides/\(driverId)/stop",
                method: .post,
                body: bodyData
            )

            let ride: Ride = try await api.send(endpoint)
            currentRide = ride
            lastCompletedRide = ride
            
            // Save ride to local history
            saveRideToHistory(ride)
            
            stopTimer()
            isRiding = false

        } catch {
            errorMessage = error.localizedDescription
            // Stop ride locally even if API fails
            stopTimer()
            isRiding = false
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

        // Simulate realistic city driving speed (30-60 km/h)
        currentSpeed = Double.random(in: 30...60)
        speedReadings.append(currentSpeed)
        
        // Distance = speed (km/h) / 3600 (to get km/s) * 1 second
        let distanceThisSecond = currentSpeed / 3600.0
        distanceTravelled += distanceThisSecond
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
    
    /// Saves completed ride to local history for offline access
    private func saveRideToHistory(_ ride: Ride) {
        // Parse dates from ISO8601 strings
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let startDate = formatter.date(from: ride.startTime) ?? Date()
        let endDate: Date
        if let endTimeStr = ride.endTime {
            endDate = formatter.date(from: endTimeStr) ?? Date()
        } else {
            endDate = Date()
        }
        
        let record = RideRecord(
            startTime: startDate,
            endTime: endDate,
            distance: ride.distanceKm ?? distanceTravelled,
            duration: TimeInterval(ride.duration ?? Int(elapsedTime)),
            averageSpeed: ride.averageSpeedKmh ?? averageSpeedKmh,
            campaignName: ride.displayCampaignName
        )
        
        historyService.addRide(record)
    }
}
