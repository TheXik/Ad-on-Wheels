import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    // Header Stats
    @Published var distanceDriven: Double = 0
    @Published var distanceRemaining: Double = 0
    @Published var monthlyGoalProgress: Double = 0 // 0.0 to 1.0
    @Published var monthlyGoalTotal: Double = 200.0 // TODO: Make this configurable

    // Quick Stats
    @Published var daysLeft: Int = 0
    @Published var totalEarnings: Double = 0
    @Published var driverRating: Double = 0

    // Greeting
    @Published var driverName: String = ""

    // Home page data
    @Published var homePageData: DriverHomePageResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
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

        // Update stats from statistics
        if let stats = response.statistics {
            // For now, map completed rides to distance driven (placeholder logic)
            // TODO: Update when backend provides actual distance metrics
            distanceDriven = Double(stats.completedRides) * 10.0 // Mock: 10km per ride
            distanceRemaining = monthlyGoalTotal - distanceDriven
            monthlyGoalProgress = min(distanceDriven / monthlyGoalTotal, 1.0)

            // TODO: Calculate from campaign duration when available
            daysLeft = 18

            // TODO: Get from backend when earnings are implemented
            totalEarnings = 0

            // TODO: Get from backend when rating is implemented
            driverRating = 0
        }
    }
}
