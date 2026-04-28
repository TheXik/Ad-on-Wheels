import SwiftUI

struct DriverRootView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var rideViewModel: RideViewModel
    @StateObject private var browseViewModel: BrowseViewModel
    @StateObject private var dashboardViewModel: DashboardViewModel
    @State private var selectedTab: Int = 0
    @State private var showingRideSheet = false
    @State private var showingQRSheet = false
    @State private var showingNoCampaignAlert = false

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(authService: AuthenticationService) {
        self.authService = authService
        _rideViewModel = StateObject(wrappedValue: RideViewModel(authService: authService))
        _browseViewModel = StateObject(wrappedValue: BrowseViewModel(driverId: authService.userId ?? 0))
        _dashboardViewModel = StateObject(wrappedValue: DashboardViewModel(authService: authService))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    NavigationView {
                        DashboardView(authService: authService, viewModel: dashboardViewModel, rideViewModel: rideViewModel) {
                            showingQRSheet = true
                        }
                        .navigationBarHidden(true)
                    }
                case 1:
                    NavigationView {
                        BrowseView(viewModel: browseViewModel)
                            .navigationBarHidden(true)
                    }
                case 2:
                    StatsView(authService: authService)
                case 3:
                    ProfileView(authService: authService)
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 90)

            customTabBar
        }
        .edgesIgnoringSafeArea(.bottom)
        .fullScreenCover(isPresented: $showingRideSheet) {
            RidingView(viewModel: rideViewModel) {
                showingRideSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingQRSheet = true
                }
            }
        }
        .fullScreenCover(isPresented: $showingQRSheet) {
            QRScanView(
                onScanComplete: { showingQRSheet = false },
                rideViewModel: rideViewModel
            )
        }
        .onAppear {
            // UC013: Start background GPS buffering so deferred rides are possible
            rideViewModel.requestLocationPermission()
            rideViewModel.startGPSBuffering()
        }
        .alert("Ride Error", isPresented: .constant(rideViewModel.errorMessage != nil)) {
            Button("OK") {
                rideViewModel.errorMessage = nil
            }
        } message: {
            Text(rideViewModel.errorMessage ?? "")
        }
        .alert("No accepted campaign", isPresented: $showingNoCampaignAlert) {
            Button("Find a campaign") {
                showingNoCampaignAlert = false
                selectedTab = 1
            }
            Button("Cancel", role: .cancel) { showingNoCampaignAlert = false }
        } message: {
            Text("You need at least one accepted campaign before you can record a ride. Browse the available campaigns and apply to one to get started.")
        }
    }

    var customTabBar: some View {
        ZStack {
            HStack {
                tabBarButton(icon: "house.fill", label: "Home", index: 0)
                tabBarButton(icon: "car.fill", label: "Browse", index: 1)

                Spacer().frame(width: 70)

                tabBarButton(icon: "chart.bar.fill", label: "Stats", index: 2)
                tabBarButton(icon: "person.fill", label: "Profile", index: 3)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 24)
            .background(
                Color(UIColor.systemBackground)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -4)
            )

            Button(action: startRideFlow) {
                ZStack {
                    Circle()
                        .fill(brandBlue)
                        .frame(width: 60, height: 60)
                        .shadow(color: brandBlue.opacity(0.4), radius: 8, x: 0, y: 4)

                    Image(systemName: "play.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -20)
        }
    }

    func tabBarButton(icon: String, label: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(selectedTab == index ? brandBlue : .gray)
            .frame(maxWidth: .infinity)
        }
    }

    func startRideFlow() {
        guard let activeCampaign = dashboardViewModel.activeCampaigns.first else {
            showingNoCampaignAlert = true
            return
        }
        rideViewModel.activeCampaignId = activeCampaign.id
        rideViewModel.activeCampaignName = activeCampaign.name
        rideViewModel.activeCampaignRatePerKm = activeCampaign.ratePerKm
        Task {
            await rideViewModel.startRide(campaignId: activeCampaign.id)
            if rideViewModel.errorMessage == nil {
                showingRideSheet = true
            }
        }
    }
}

