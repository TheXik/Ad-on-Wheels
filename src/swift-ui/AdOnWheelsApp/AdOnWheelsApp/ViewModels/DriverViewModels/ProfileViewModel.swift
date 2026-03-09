import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var driver: Driver?
    @Published var statistics: RideStatistics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Computed properties from backend data
    var driverName: String {
        driver?.name ?? "Driver"
    }
    
    var totalRides: Int {
        statistics?.totalRides ?? 0
    }
    
    var totalEarnings: Double {
        statistics?.totalEarnings ?? 0
    }
    
    var driverRating: Double {
        driver?.rating ?? 0
    }
    
    var memberSince: String {
        if let date = driver?.memberSince {
            return date
        }
        return formatMemberSince()
    }
    
    var currentBalance: Double {
        statistics?.totalEarnings ?? 0
    }
    
    // Vehicle info from backend
    var vehicleMake: String {
        driver?.vehicleMake ?? ""
    }
    
    var vehicleModel: String {
        driver?.vehicleModel ?? ""
    }
    
    var vehicleYear: String {
        if let year = driver?.vehicleYear {
            return String(year)
        }
        return ""
    }
    
    var vehiclePlate: String {
        driver?.vehiclePlate ?? ""
    }
    
    var vehicleColor: String {
        driver?.vehicleColor ?? ""
    }
    
    var isVehicleVerified: Bool {
        driver?.vehicleVerified ?? false
    }
    
    private let api: APIClientProtocol
    private let authService: AuthenticationService
    
    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
    }
    
    func fetchProfile() async {
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            // Fetch driver info and statistics via home endpoint
            let endpoint = Endpoint(path: "api/drivers/\(driverId)/home")
            let response: DriverHomePageResponse = try await api.send(endpoint)
            
            self.driver = response.driver
            self.statistics = response.statistics
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func formatMemberSince() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: Date())
    }
    
    var hasVehicle: Bool {
        !vehicleMake.isEmpty && !vehicleModel.isEmpty
    }
    
    var formattedTotalEarnings: String {
        if totalEarnings >= 1000 {
            return String(format: "€%.1fk", totalEarnings / 1000)
        }
        return String(format: "€%.0f", totalEarnings)
    }
    
    var formattedBalance: String {
        String(format: "€%.2f", currentBalance)
    }
    
    var formattedRating: String {
        String(format: "%.1f", driverRating)
    }
    
    var vehicleDisplayName: String {
        driver?.vehicleDisplayName ?? "No vehicle"
    }
}
