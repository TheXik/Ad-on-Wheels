import SwiftUI

struct DashboardView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel: DashboardViewModel
    @StateObject private var rideViewModel: RideViewModel

    // UI State
    @State private var scrollOffset: CGFloat = 0
    @State private var isHeaderCollapsed: Bool = false
    @State private var showingRideSheet: Bool = false
    @State private var showingQRSheet: Bool = false

    // Verification State
    @State private var showingVerification = false
    @State private var isVerified = false

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(authService: AuthenticationService) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: DashboardViewModel(authService: authService))
        _rideViewModel = StateObject(wrappedValue: RideViewModel(authService: authService))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        DashboardHeaderView(viewModel: viewModel)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 20) {
                        Spacer().frame(height: 10)
                        
                        // Action Required (Verification)
                        Button(action: {
                            if !isVerified {
                                showingVerification = true
                            }
                        }) {
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(isVerified ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: isVerified ? "checkmark.seal.fill" : "camera.fill")
                                        .font(.title2)
                                        .foregroundColor(isVerified ? .green : .orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(isVerified ? "Weekly Check Complete" : "Weekly Verification Required")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(isVerified ? "You are all set for this week." : "Upload photo of passenger side decal")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if !isVerified {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isVerified)
                        
                        // Active Campaign
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Campaign")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            NavigationLink(destination: CampaignDetailView()) {
                                DashboardCardView(
                                    iconName: "megaphone.fill",
                                    title: "Firma XYZ",
                                    subtitle: "Current Ad",
                                    content: "Duration: 14. 3. - 12. 4.",
                                    subContent: "Reward: 100€ / month"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Messages
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Messages")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            NavigationLink(destination: InboxView()) {
                                DashboardCardView(
                                    iconName: "envelope.fill",
                                    title: "New terms available",
                                    subtitle: "System Message",
                                    content: "Please check the new terms...",
                                    subContent: nil
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        

                        
                        Spacer().frame(height: 120) // Bottom padding for FAB
                    }
                    .padding(20)
                }
                }
            }
            
            // Floating Start Ride Button
            VStack {
                Spacer()
                Button(action: {
                    startRideFlow()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Ride")
                            .fontWeight(.bold)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(brandBlue)
                    .clipShape(Capsule())
                    .shadow(color: brandBlue.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 30) // Lift up from bottom
            }
        }
        .fullScreenCover(isPresented: $showingRideSheet) {
            RidingView(viewModel: rideViewModel) {
                // On End Ride -> Switch to QR
                showingRideSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingQRSheet = true
                }
            }
        }
        .fullScreenCover(isPresented: $showingQRSheet) {
            QRScanView {
                // On Finish -> Back to Dashboard
                showingQRSheet = false
            }
        }
        .fullScreenCover(isPresented: $showingVerification) {
            VerificationCameraView {
                isVerified = true
            }
        }
        .task {
            await viewModel.fetchDashboardData()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Ride Error", isPresented: .constant(rideViewModel.errorMessage != nil)) {
            Button("OK") {
                rideViewModel.errorMessage = nil
            }
        } message: {
            Text(rideViewModel.errorMessage ?? "")
        }
    }

    func startRideFlow() {
        Task {
            await rideViewModel.startRide()
            showingRideSheet = true
        }
    }
}


struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(authService: AuthenticationService())
    }
}
