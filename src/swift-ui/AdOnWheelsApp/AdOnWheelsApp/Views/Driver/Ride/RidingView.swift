import SwiftUI
import MapKit

struct RidingView: View {
    @ObservedObject var viewModel: RideViewModel
    var onEndRide: () -> Void
    
    // Mock Map Region
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.1486, longitude: 17.1077), // Bratislava
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Full Screen Map
            Map(coordinateRegion: $region, showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.1)) // Dim slightly for overlay contrast
            
            // Top HUD
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current Campaign")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(4)
                        
                        Text("Firma XYZ")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                    }
                    Spacer()
                    // Timer Mock
                    Text(viewModel.timeString)
                        .font(.monospacedDigit(.title)())
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)
                }
                .padding(.top, 50)
                .padding(.horizontal)
                
                Spacer()
            }
            
            // Bottom Stats Sheet
            VStack(spacing: 20) {
                HStack(spacing: 40) {
                    VStack {
                        Text("Speed")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.0f", viewModel.currentSpeed))
                            .font(.system(size: 32, weight: .bold))
                        Text("km/h")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("Distance")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.2f", viewModel.distanceTravelled))
                            .font(.system(size: 32, weight: .bold))
                        Text("km")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // End Ride Button
                Button(action: {
                    Task {
                        await viewModel.endRide()
                        onEndRide()
                    }
                }) {
                    Text("End Ride")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(15)
                }
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(30, corners: [.topLeft, .topRight])
            .shadow(radius: 10)
        }
    }
}

struct RidingView_Previews: PreviewProvider {
    static var previews: some View {
        RidingView(viewModel: RideViewModel(authService: AuthenticationService())) {}
    }
}
