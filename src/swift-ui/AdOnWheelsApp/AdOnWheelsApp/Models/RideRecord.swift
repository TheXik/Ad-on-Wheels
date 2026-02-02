import Foundation

struct RideRecord: Identifiable, Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let distance: Double // in km
    let duration: TimeInterval // in seconds
    let averageSpeed: Double // km/h
    let earnings: Double // calculated based on distance
    let campaignName: String
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date, distance: Double, duration: TimeInterval, averageSpeed: Double, campaignName: String = "Firma XYZ") {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.distance = distance
        self.duration = duration
        self.averageSpeed = averageSpeed
        self.campaignName = campaignName
        // Earnings: 0.33€ per km (example rate)
        self.earnings = distance * 0.33
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: startTime)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(startTime)
    }
    
    var relativeDate: String {
        if Calendar.current.isDateInToday(startTime) {
            return "Today, \(formattedTime)"
        } else if Calendar.current.isDateInYesterday(startTime) {
            return "Yesterday, \(formattedTime)"
        } else {
            return "\(formattedDate), \(formattedTime)"
        }
    }
}
