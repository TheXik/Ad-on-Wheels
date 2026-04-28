import SwiftUI
import Combine

@MainActor
class StatsViewModel: ObservableObject {
    @Published var statistics: RideStatistics?
    @Published var recentRides: [Ride] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Computed properties from backend stats
    var weeklyEarnings: Double {
        statistics?.weeklyEarnings ?? 0
    }
    
    var weeklyDistance: Double {
        statistics?.weeklyDistanceKm ?? 0
    }
    
    var monthlyEarnings: Double {
        statistics?.monthlyEarnings ?? 0
    }
    
    var monthlyDistance: Double {
        statistics?.monthlyDistanceKm ?? 0
    }
    
    var totalEarnings: Double {
        statistics?.totalEarnings ?? 0
    }
    
    var totalDistance: Double {
        statistics?.totalDistanceKm ?? 0
    }
    
    var totalRides: Int {
        statistics?.totalRides ?? 0
    }
    
    var averageSpeed: Double {
        statistics?.averageSpeedKmh ?? 0
    }
    
    private let api: APIClientProtocol
    private let authService: AuthenticationService
    private var rideCompletedObserver: Any?

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
        // Auto-refresh stats whenever a ride finishes
        rideCompletedObserver = NotificationCenter.default.addObserver(
            forName: .rideCompleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { await self?.fetchStats() }
        }
    }

    deinit {
        if let observer = rideCompletedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func fetchStats() async {
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Fetch statistics
            let statsEndpoint = Endpoint(path: "api/drivers/\(driverId)/statistics")
            let stats: RideStatistics = try await api.send(statsEndpoint)
            self.statistics = stats
            
            // Fetch recent rides (limit covers a typical week of activity, used by the
            // 7-day earnings chart in dailyEarnings)
            let ridesEndpoint = Endpoint(
                path: "api/drivers/\(driverId)/rides",
                queryItems: [URLQueryItem(name: "limit", value: "100")]
            )
            let rides: [Ride] = try await api.send(ridesEndpoint)
            self.recentRides = rides
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func earnings(for period: Int) -> Double {
        period == 0 ? weeklyEarnings : monthlyEarnings
    }
    
    func distance(for period: Int) -> Double {
        period == 0 ? weeklyDistance : monthlyDistance
    }
    
    func formattedEarnings(for period: Int) -> String {
        String(format: "€%.2f", earnings(for: period))
    }
    
    func formattedDistance(for period: Int) -> String {
        String(format: "%.1f km", distance(for: period))
    }
    
    /// Earnings grouped by day for the last seven days, oldest first.
    /// Rides are bucketed by their end-time calendar day in the user's
    /// current timezone. Only verified rides contribute to earnings totals
    /// (matches the postcondition of UC01).
    var dailyEarnings: [Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var buckets = [Double](repeating: 0, count: 7)
        for ride in recentRides {
            guard ride.verified == true else { continue }
            guard let endString = ride.endTime,
                  let endDate = StatsViewModel.parseLocalDateTime(endString) else { continue }
            let rideDay = calendar.startOfDay(for: endDate)
            guard let daysAgo = calendar.dateComponents([.day], from: rideDay, to: today).day else { continue }
            guard daysAgo >= 0 && daysAgo < 7 else { continue }
            let index = 6 - daysAgo
            buckets[index] += ride.earnings ?? 0
        }
        return buckets
    }

    /// Parses Spring's default `LocalDateTime` serialization, which has no
    /// timezone and may or may not carry fractional seconds. iOS'
    /// `ISO8601DateFormatter` requires a timezone so we use `DateFormatter`
    /// pinned to the device's current timezone (matching what the server
    /// emits for `LocalDateTime`).
    static func parseLocalDateTime(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        for format in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS",
                       "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                       "yyyy-MM-dd'T'HH:mm:ss.SSS",
                       "yyyy-MM-dd'T'HH:mm:ss"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: value) {
                return date
            }
        }
        return nil
    }
}
