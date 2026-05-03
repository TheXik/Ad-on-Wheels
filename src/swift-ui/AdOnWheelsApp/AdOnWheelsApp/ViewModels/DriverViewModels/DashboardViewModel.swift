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
    @Published var totalRides: Int = 0
    @Published var monthlyRides: Int = 0
    @Published var averageSpeed: Double = 0

    // Greeting
    @Published var driverName: String = ""

    // Active campaigns (driver is enrolled in)
    @Published var activeCampaigns: [Campaign] = []

    // All driver applications (pending, accepted, declined)
    @Published var myApplications: [ApplicationWithCampaign] = []

    // Messages
    @Published var unreadMessageCount: Int = 0

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
            updateUIFromResponse(response)
        } catch {
            self.errorMessage = error.localizedDescription
        }

        await fetchDriverCampaigns(driverId: driverId)
        await fetchDriverApplications(driverId: driverId)
        await fetchUnreadMessages(userId: driverId)
    }

    private func fetchDriverCampaigns(driverId: Int) async {
        do {
            let endpoint = Endpoint(path: "api/campaigns/driver/\(driverId)")
            var campaigns: [Campaign] = try await api.send(endpoint)
            await resolveCompanyNames(&campaigns)
            self.activeCampaigns = campaigns
        } catch {
            self.activeCampaigns = []
        }
    }

    private func fetchDriverApplications(driverId: Int) async {
        do {
            let endpoint = Endpoint(path: "api/campaigns/driver/\(driverId)/applications")
            let apps: [ApplicationWithCampaign] = try await api.send(endpoint)
            self.myApplications = apps
        } catch {
            self.myApplications = []
        }
    }

    func withdrawApplication(_ application: ApplicationWithCampaign) async {
        guard application.status.uppercased() == "APPLIED",
              let driverId = authService.userId else { return }
        do {
            let endpoint = Endpoint(
                path: "api/campaigns/applications/\(application.id)",
                method: .delete,
                queryItems: [URLQueryItem(name: "driverId", value: String(driverId))]
            )
            try await api.send(endpoint)
            myApplications.removeAll { $0.id == application.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var pendingApplicationCount: Int {
        myApplications.filter { $0.status.uppercased() == "APPLIED" }.count
    }

    private func fetchUnreadMessages(userId: Int) async {
        do {
            let endpoint = Endpoint(path: "api/messages/inbox/\(userId)")
            let messages: [Message] = try await api.send(endpoint)
            self.unreadMessageCount = messages.filter { !$0.isRead }.count
        } catch {
            self.unreadMessageCount = 0
        }
    }

    private func resolveCompanyNames(_ campaigns: inout [Campaign]) async {
        let uniqueIds = Set(campaigns.map { $0.companyId })
        var nameMap: [Int: String] = [:]
        for companyId in uniqueIds {
            do {
                let endpoint = Endpoint(path: "api/companies/\(companyId)")
                let company: Company = try await api.send(endpoint)
                nameMap[companyId] = company.name
            } catch {
                nameMap[companyId] = "Company"
            }
        }
        for i in campaigns.indices {
            campaigns[i].companyName = nameMap[campaigns[i].companyId]
        }
    }

    private func updateUIFromResponse(_ response: DriverHomePageResponse) {
        driverName = response.driver.name

        if let backendGoal = response.driver.monthlyGoalKm, backendGoal > 0 {
            monthlyGoalTotal = backendGoal
        }

        if let stats = response.statistics {
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
            
            averageSpeed = stats.averageSpeedKmh ?? 0
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
