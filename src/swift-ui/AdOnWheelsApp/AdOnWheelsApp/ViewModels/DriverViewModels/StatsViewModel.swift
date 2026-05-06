import SwiftUI

@MainActor
class StatsViewModel: ObservableObject {
    @Published var statistics: RideStatistics?
    @Published var recentRides: [Ride] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

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

    var totalRides: Int {
        Int(statistics?.totalRides ?? 0)
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
            let statsEndpoint = Endpoint(path: "api/drivers/\(driverId)/statistics")
            let stats: RideStatistics = try await api.send(statsEndpoint)
            self.statistics = stats
            
            // 500 covers ~a month at typical activity, enough for the 30-day chart.
            let ridesEndpoint = Endpoint(
                path: "api/drivers/\(driverId)/rides",
                queryItems: [URLQueryItem(name: "limit", value: "500")]
            )
            let rides: [Ride] = try await api.send(ridesEndpoint)
            self.recentRides = rides

        } catch {
            if error.isCancellation { return }
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
    
    // Daily earnings over the requested window, oldest first. Verified rides
    // only, to match the backend's weekly/monthly earnings totals.
    func dailyEarnings(_ days: Int = 7) -> [Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var buckets = [Double](repeating: 0, count: days)
        for ride in recentRides {
            guard ride.verified == true else { continue }
            guard let endString = ride.endTime,
                  let endDate = StatsViewModel.parseLocalDateTime(endString) else { continue }
            let rideDay = calendar.startOfDay(for: endDate)
            guard let daysAgo = calendar.dateComponents([.day], from: rideDay, to: today).day else { continue }
            guard daysAgo >= 0 && daysAgo < days else { continue }
            let index = days - 1 - daysAgo
            buckets[index] += ride.earnings ?? 0
        }
        return buckets
    }

    // Server LocalDateTime has no zone designator but is UTC; force UTC
    // here so day-binning matches RideDetailView.parseBackendDate.
    static func parseLocalDateTime(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
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
