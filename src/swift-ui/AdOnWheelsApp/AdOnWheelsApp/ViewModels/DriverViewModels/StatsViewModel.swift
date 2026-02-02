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
    
    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService = AuthenticationService.shared) {
        self.api = api
        self.authService = authService
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
            
            // Fetch recent rides
            let ridesEndpoint = Endpoint(
                path: "api/drivers/\(driverId)/rides",
                queryItems: [URLQueryItem(name: "limit", value: "10")]
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
    
    // Daily earnings (placeholder - would need daily aggregation endpoint)
    var dailyEarnings: [Double] {
        // TODO: Add daily aggregation endpoint to backend
        // For now return estimated split
        let weekly = weeklyEarnings
        if weekly == 0 { return Array(repeating: 0, count: 7) }
        let daily = weekly / 7.0
        return Array(repeating: daily, count: 7)
    }
}
