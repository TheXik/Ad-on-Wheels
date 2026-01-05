import SwiftUI

class DashboardViewModel: ObservableObject {
    // Header Stats
    @Published var distanceDriven: Double = 45.2
    @Published var distanceRemaining: Double = 44.8
    @Published var monthlyGoalProgress: Double = 0.51 // 0.0 to 1.0
    @Published var monthlyGoalTotal: Double = 90.0 // Derived or explicit total
    
    // Quick Stats
    @Published var daysLeft: Int = 12
    @Published var totalEarnings: Double = 345.50
    @Published var driverRating: Double = 4.9
    
    // Greeting
    @Published var driverName: String = "Lukas"
    
    init() {
        // Simulating data loading or randomizing for "mock" feel
        loadMockData()
    }
    
    func loadMockData() {
        // In a real app, this would fetch from an API
        // For now, we can just keep the initial values or randomize them if desired
        distanceDriven = 124.5
        distanceRemaining = 75.5
        monthlyGoalTotal = 200.0
        monthlyGoalProgress = distanceDriven / monthlyGoalTotal
        
        daysLeft = 18
        totalEarnings = 420.00
        driverRating = 5.0
    }
}
