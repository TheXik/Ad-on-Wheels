import SwiftUI
import MapKit

private struct MapAnnotationItem: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
}

private struct MockCompany: Identifiable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D

    init(_ name: String, _ latitude: Double, _ longitude: Double) {
        self.id = UUID()
        self.name = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
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

    private static let mockCompanies: [MockCompany] = [
        MockCompany("Tesco", 50.0780, 14.4350),
        MockCompany("Lidl", 50.0730, 14.4420),
        MockCompany("Billa", 50.0810, 14.4480),
        MockCompany("Kaufland", 50.0760, 14.4530),
    ]

    private var allAnnotations: [MapAnnotationItem] {
        var items = Self.mockCompanies.map {
            MapAnnotationItem(id: $0.name, coordinate: $0.coordinate)
        }
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
                    if item.id == "user" {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 4)
                    } else {
                        VStack(spacing: 2) {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.blue)
                                .padding(6)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                            Text(item.id)
                                .font(.system(size: 10, weight: .medium))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .overlay(Color.black.opacity(0.1))
            .onAppear {
                viewModel.requestLocationPermission()
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
