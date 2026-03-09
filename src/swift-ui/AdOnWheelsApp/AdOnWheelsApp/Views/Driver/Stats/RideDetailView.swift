import SwiftUI
import MapKit

struct RideDetailView: View {
    let ride: Ride
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Map Header
                Map(coordinateRegion: $region)
                    .frame(height: 300)
                    .edgesIgnoringSafeArea(.top)
                    .disabled(true)
                
                VStack(spacing: 20) {
                    // Header Status
                    HStack {
                        VStack(alignment: .leading) {
                            Text(formattedDate)
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(statusText)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(statusColor)
                        }
                        Spacer()
                        Text(ride.formattedEarnings)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 20)
                    
                    Divider()
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        DetailStatBox(title: "Distance", value: ride.formattedDistance)
                        DetailStatBox(title: "Duration", value: ride.formattedDuration)
                        DetailStatBox(title: "Avg Speed", value: String(format: "%.0f km/h", ride.averageSpeedKmh ?? 0))
                        DetailStatBox(title: "Campaign", value: ride.displayCampaignName)
                    }
                    
                    Divider()
                    
                    // Route Info
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Route Info")
                            .font(.headline)
                        
                        HStack {
                            Circle().fill(Color.green).frame(width: 10, height: 10)
                            Text("\(formattedStartTime) Start")
                                .font(.subheadline)
                        }
                        
                        if let startLocation = ride.startLocation {
                            Text(startLocation)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 14)
                        }
                        
                        HStack {
                             Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 2, height: 20).padding(.leading, 4)
                        }
                        
                        HStack {
                            Circle().fill(Color.red).frame(width: 10, height: 10)
                            Text("\(formattedEndTime) End")
                                .font(.subheadline)
                        }
                        
                        if let endLocation = ride.endLocation {
                            Text(endLocation)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 14)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .padding()
            }
        }
        .navigationBarTitle("Ride Details", displayMode: .inline)
    }
    
    private var statusText: String {
        switch ride.status {
        case "ACTIVE": return "In Progress"
        case "COMPLETED": return "Completed"
        case "VERIFIED": return "Verified"
        case "CANCELLED": return "Cancelled"
        default: return ride.status
        }
    }
    
    private var statusColor: Color {
        switch ride.status {
        case "ACTIVE": return .blue
        case "COMPLETED": return .green
        case "VERIFIED": return .purple
        case "CANCELLED": return .red
        default: return .gray
        }
    }
    
    private var formattedDate: String {
        // Parse ISO8601 date string
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: ride.startTime) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, yyyy"
            return displayFormatter.string(from: date)
        }
        return ride.startTime
    }
    
    private var formattedStartTime: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: ride.startTime) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        return "--:--"
    }
    
    private var formattedEndTime: String {
        guard let endTime = ride.endTime else { return "--:--" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: endTime) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: date)
        }
        return "--:--"
    }
}

struct DetailStatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct RideDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RideDetailView(ride: Ride(
            id: 1,
            driverId: 1,
            campaignId: 1,
            startTime: "2024-01-15T10:00:00",
            endTime: "2024-01-15T11:00:00",
            startLocation: nil,
            endLocation: nil,
            duration: 3600,
            qrCodeData: nil,
            status: "COMPLETED",
            campaignName: "Test Campaign",
            distanceKm: 25.5,
            averageSpeedKmh: 45.0,
            earnings: 3.83
        ))
    }
}
