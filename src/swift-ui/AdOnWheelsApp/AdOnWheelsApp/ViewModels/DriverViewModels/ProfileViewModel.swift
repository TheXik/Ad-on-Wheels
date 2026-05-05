import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var driver: Driver?
    @Published var statistics: RideStatistics?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var driverName: String {
        driver?.name ?? "Driver"
    }
    
    var totalRides: Int {
        Int(statistics?.totalRides ?? 0)
    }

    var totalEarnings: Double {
        statistics?.totalEarnings ?? 0
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
    
    var vehicleMake: String {
        driver?.vehicleMake ?? ""
    }
    
    var vehicleModel: String {
        driver?.vehicleModel ?? ""
    }
    
    var vehicleYear: String {
        driver?.vehicleYear ?? ""
    }
    
    var vehiclePlate: String {
        driver?.vehiclePlate ?? ""
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
            let endpoint = Endpoint(path: "api/drivers/\(driverId)/home")
            let response: DriverHomePageResponse = try await api.send(endpoint)
            
            self.driver = response.driver
            self.statistics = response.statistics

        } catch {
            if error.isCancellation { return }
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func formatMemberSince() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: Date())
    }
    
    @Published var isSavingVehicle = false
    @Published var vehicleSaveSuccess = false

    func saveVehicle(make: String, model: String, year: String, plate: String) async {
        guard let driverId = authService.userId else { return }

        isSavingVehicle = true
        vehicleSaveSuccess = false
        errorMessage = nil
        defer { isSavingVehicle = false }

        do {
            let body: [String: String] = [
                "make": make,
                "model": model,
                "year": year,
                "licensePlate": plate
            ]
            let data = try JSONEncoder().encode(body)
            let endpoint = Endpoint(
                path: "api/drivers/\(driverId)/vehicle",
                method: .patch,
                body: data
            )
            let _: Driver = try await api.send(endpoint)
            vehicleSaveSuccess = true
            await fetchProfile()
        } catch {
            if error.isCancellation { return }
            errorMessage = error.localizedDescription
        }
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
}
