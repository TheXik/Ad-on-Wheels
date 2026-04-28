import SwiftUI
import MapKit

private struct MapAnnotationItem: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
}

struct RidingView: View {
    @ObservedObject var viewModel: RideViewModel
    var onEndRide: () -> Void

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var hasInitializedRegion = false

    #if DEBUG
    @State private var isSimulating = false
    #endif

    private var allAnnotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        if let loc = viewModel.currentLocation {
            items.append(MapAnnotationItem(id: "user", coordinate: loc))
        }
        return items
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(
                coordinateRegion: $region,
                showsUserLocation: false,
                annotationItems: allAnnotations
            ) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 4)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .overlay(Color.black.opacity(0.1))
            .onAppear {
                viewModel.requestLocationPermission()
                if let coord = viewModel.currentLocation, !hasInitializedRegion {
                    region = MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    hasInitializedRegion = true
                }
            }
            .onChange(of: viewModel.locationVersion) { _ in
                guard let coord = viewModel.currentLocation else { return }
                if !hasInitializedRegion {
                    region = MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    hasInitializedRegion = true
                } else {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        region.center = coord
                    }
                }
            }

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

                        Text(viewModel.activeCampaignName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(8)
                    }
                    Spacer()
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

                #if DEBUG
                Button(action: {
                    isSimulating.toggle()
                    if isSimulating {
                        viewModel.startSimulatedMovement()
                    } else {
                        viewModel.stopSimulatedMovement()
                    }
                }) {
                    Text(isSimulating ? "Stop Simulation" : "Simulate Movement")
                        .font(.subheadline)
                        .foregroundColor(isSimulating ? .orange : .blue)
                }
                #endif

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
            .background(Color(UIColor.systemBackground))
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
