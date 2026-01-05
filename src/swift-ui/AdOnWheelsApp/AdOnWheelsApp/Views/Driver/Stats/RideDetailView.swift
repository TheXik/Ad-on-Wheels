import SwiftUI
import MapKit

struct RideDetailView: View {
    var date: String = "Today, 14:30"
    var earnings: String = "€4.20"
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.1486, longitude: 17.1077),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Map Header
                Map(coordinateRegion: $region)
                    .frame(height: 300)
                    .edgesIgnoringSafeArea(.top)
                    .disabled(true) // Static for mock
                
                VStack(spacing: 20) {
                    // Header Status
                    HStack {
                        VStack(alignment: .leading) {
                            Text(date)
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Completed")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Text(earnings)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.top, 20)
                    
                    Divider()
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        DetailStatBox(title: "Distance", value: "12.5 km")
                        DetailStatBox(title: "Duration", value: "24m")
                        DetailStatBox(title: "Avg Speed", value: "48 km/h")
                        DetailStatBox(title: "Bonus", value: "€0.00")
                    }
                    
                    Divider()
                    
                    // Route Breakdown (Mock)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Route Info")
                            .font(.headline)
                        
                        HStack {
                            Circle().fill(Color.green).frame(width: 10, height: 10)
                            Text("14:30 Start: Ružinov")
                                .font(.subheadline)
                        }
                        HStack {
                             Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 2, height: 20).padding(.leading, 4)
                        }
                        HStack {
                            Circle().fill(Color.red).frame(width: 10, height: 10)
                            Text("14:54 End: Staré Mesto")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .padding()
            }
        }
        .navigationBarTitle("Ride Details", displayMode: .inline)
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
        RideDetailView()
    }
}
