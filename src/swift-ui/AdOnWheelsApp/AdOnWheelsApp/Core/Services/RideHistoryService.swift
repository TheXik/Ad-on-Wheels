import Foundation

class RideHistoryService: ObservableObject {
    static let shared = RideHistoryService()
    
    @Published private(set) var rides: [RideRecord] = []
    
    private let userDefaultsKey = "savedRides"
    
    private init() {
        loadRides()
    }
    
    var totalDistance: Double {
        rides.reduce(0) { $0 + $1.distance }
    }
    
    var totalEarnings: Double {
        rides.reduce(0) { $0 + $1.earnings }
    }
    
    var totalRides: Int {
        rides.count
    }
    
    var averageSpeed: Double {
        guard !rides.isEmpty else { return 0 }
        return rides.reduce(0) { $0 + $1.averageSpeed } / Double(rides.count)
    }
    
    var totalDuration: TimeInterval {
        rides.reduce(0) { $0 + $1.duration }
    }
    
    // Weekly stats
    var weeklyDistance: Double {
        ridesThisWeek.reduce(0) { $0 + $1.distance }
    }
    
    var weeklyEarnings: Double {
        ridesThisWeek.reduce(0) { $0 + $1.earnings }
    }
    
    var ridesThisWeek: [RideRecord] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return rides.filter { $0.startTime >= weekAgo }
    }
    
    // Monthly stats
    var monthlyDistance: Double {
        ridesThisMonth.reduce(0) { $0 + $1.distance }
    }
    
    var monthlyEarnings: Double {
        ridesThisMonth.reduce(0) { $0 + $1.earnings }
    }
    
    var ridesThisMonth: [RideRecord] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        return rides.filter { $0.startTime >= startOfMonth }
    }
    
    var monthlyRideCount: Int {
        ridesThisMonth.count
    }
    
    // Daily earnings for chart (last 7 days)
    func earningsPerDay() -> [Double] {
        let calendar = Calendar.current
        var dailyEarnings: [Double] = Array(repeating: 0, count: 7)
        
        for i in 0..<7 {
            let targetDate = calendar.date(byAdding: .day, value: -(6-i), to: Date())!
            let dayStart = calendar.startOfDay(for: targetDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            dailyEarnings[i] = rides
                .filter { $0.startTime >= dayStart && $0.startTime < dayEnd }
                .reduce(0) { $0 + $1.earnings }
        }
        
        return dailyEarnings
    }
    
    func distancePerDay() -> [Double] {
        let calendar = Calendar.current
        var dailyDistance: [Double] = Array(repeating: 0, count: 7)
        
        for i in 0..<7 {
            let targetDate = calendar.date(byAdding: .day, value: -(6-i), to: Date())!
            let dayStart = calendar.startOfDay(for: targetDate)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            dailyDistance[i] = rides
                .filter { $0.startTime >= dayStart && $0.startTime < dayEnd }
                .reduce(0) { $0 + $1.distance }
        }
        
        return dailyDistance
    }
    
    func addRide(_ ride: RideRecord) {
        rides.insert(ride, at: 0) // Newest first
        saveRides()
    }
    
    func clearAllRides() {
        rides.removeAll()
        saveRides()
    }
    
    func deleteRide(_ ride: RideRecord) {
        rides.removeAll { $0.id == ride.id }
        saveRides()
    }
    
    private func saveRides() {
        if let encoded = try? JSONEncoder().encode(rides) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadRides() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([RideRecord].self, from: data) {
            rides = decoded
        }
    }
    
    var formattedTotalEarnings: String {
        if totalEarnings >= 1000 {
            return String(format: "€%.1fk", totalEarnings / 1000)
        }
        return String(format: "€%.2f", totalEarnings)
    }
    
    var formattedTotalDistance: String {
        if totalDistance >= 1000 {
            return String(format: "%.1fk km", totalDistance / 1000)
        }
        return String(format: "%.1f km", totalDistance)
    }
}
