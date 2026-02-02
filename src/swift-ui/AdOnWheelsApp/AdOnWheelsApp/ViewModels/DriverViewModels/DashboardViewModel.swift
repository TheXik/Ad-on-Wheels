import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    // Header Stats
    @Published var distanceDriven: Double = 0
    @Published var distanceRemaining: Double = 0
    @Published var monthlyGoalProgress: Double = 0 // 0.0 to 1.0
    @Published var monthlyGoalTotal: Double = 200.0

    // Quick Stats
    @Published var daysLeft: Int = 0
    @Published var totalEarnings: Double = 0
    @Published var weeklyEarnings: Double = 0
    @Published var monthlyEarnings: Double = 0
    @Published var driverRating: Double = 0
    @Published var totalRides: Int = 0
    @Published var monthlyRides: Int = 0
    @Published var averageSpeed: Double = 0

    // Greeting
    @Published var driverName: String = ""

    // Home page data
    @Published var homePageData: DriverHomePageResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()

    private let api: APIClientProtocol
    private let authService: AuthenticationService
    
    private let goalDefaultsKey = "monthlyGoalKm"

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
        
        loadSavedGoal()
        calculateDaysLeft()
    }

    func fetchDashboardData() async {
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let endpoint = Endpoint(path: "api/drivers/\(driverId)/home")
            let response: DriverHomePageResponse = try await api.send(endpoint)
            self.homePageData = response

            // Update UI properties from BFF response
            updateUIFromResponse(response)

        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private func updateUIFromResponse(_ response: DriverHomePageResponse) {
        // Update driver name
        driverName = response.driver.name

        // Update stats from statistics - ALL DATA FROM BACKEND
        if let stats = response.statistics {
            // Distance from backend
            let monthlyDistance = stats.monthlyDistanceKm ?? 0
            distanceDriven = monthlyDistance
            distanceRemaining = max(0, monthlyGoalTotal - distanceDriven)
            monthlyGoalProgress = monthlyGoalTotal > 0 ? min(distanceDriven / monthlyGoalTotal, 1.0) : 0

            // Days left in month
            calculateDaysLeft()

            // Earnings from backend
            totalEarnings = stats.totalEarnings ?? 0
            weeklyEarnings = stats.weeklyEarnings ?? 0
            monthlyEarnings = stats.monthlyEarnings ?? 0
            
            // Rides from backend
            totalRides = stats.totalRides
            monthlyRides = stats.completedRides
            
            // Speed and rating from backend
            averageSpeed = stats.averageSpeedKmh ?? 0
            driverRating = stats.rating ?? 0
        }
    }
    
    private func calculateDaysLeft() {
        let calendar = Calendar.current
        let today = Date()
        if let range = calendar.range(of: .day, in: .month, for: today) {
            let currentDay = calendar.component(.day, from: today)
            daysLeft = range.count - currentDay
        }
    }
    
    func setMonthlyGoal(_ goal: Double) {
        monthlyGoalTotal = goal
        UserDefaults.standard.set(goal, forKey: goalDefaultsKey)
        
        // Recalculate progress with new goal
        distanceRemaining = max(0, monthlyGoalTotal - distanceDriven)
        monthlyGoalProgress = monthlyGoalTotal > 0 ? min(distanceDriven / monthlyGoalTotal, 1.0) : 0
    }
    
    private func loadSavedGoal() {
        let savedGoal = UserDefaults.standard.double(forKey: goalDefaultsKey)
        if savedGoal > 0 {
            monthlyGoalTotal = savedGoal
        }
    }
    
    var formattedTotalEarnings: String {
        String(format: "€%.2f", totalEarnings)
    }
    
    var formattedWeeklyEarnings: String {
        String(format: "€%.2f", weeklyEarnings)
    }
    
    var formattedMonthlyEarnings: String {
        String(format: "€%.2f", monthlyEarnings)
    }
    
    var formattedAverageSpeed: String {
        String(format: "%.1f km/h", averageSpeed)
    }
    
    var formattedDistanceDriven: String {
        String(format: "%.1f km", distanceDriven)
    }
}
