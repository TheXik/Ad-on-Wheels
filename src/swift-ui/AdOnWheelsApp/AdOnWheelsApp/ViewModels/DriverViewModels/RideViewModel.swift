import SwiftUI
import Combine

class RideViewModel: ObservableObject {
    @Published var isRiding: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distanceTravelled: Double = 0.0
    @Published var currentSpeed: Double = 0.0
    
    // Timer
    private var timer: AnyCancellable?
    
    func startRide() {
        isRiding = true
        elapsedTime = 0
        distanceTravelled = 0.0
        currentSpeed = 45.0 // Mock speed km/h
        
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateRideMetrics()
            }
    }
    
    func endRide() {
        isRiding = false
        timer?.cancel()
        timer = nil
    }
    
    private func updateRideMetrics() {
        elapsedTime += 1
        // Mock distance calculation: 45km/h = 0.0125 km/s
        distanceTravelled += 0.0125
        
        // Vary speed slightly for "realism"
        currentSpeed = 45.0 + Double.random(in: -2...2)
    }
    
    var timeString: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}
