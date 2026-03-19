import SwiftUI

struct DashboardView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel: DashboardViewModel
    @ObservedObject var rideViewModel: RideViewModel

    @State private var scrollOffset: CGFloat = 0
    @State private var isHeaderCollapsed: Bool = false

    @State private var showingVerification = false
    @State private var isVerified = false

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(authService: AuthenticationService, rideViewModel: RideViewModel) {
        self.authService = authService
        self.rideViewModel = rideViewModel
        _viewModel = StateObject(wrappedValue: DashboardViewModel(authService: authService))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                DashboardHeaderView(viewModel: viewModel)

                ScrollView(showsIndicators: false) {
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
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isVerified)
                        
                        // Active Campaigns
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Campaigns")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)

                            if viewModel.activeCampaigns.isEmpty {
                                DashboardCardView(
                                    iconName: "megaphone",
                                    title: "No active campaigns",
                                    subtitle: "Browse",
                                    content: "Swipe through ads to find your first campaign",
                                    subContent: nil
                                )
                            } else {
                                ForEach(viewModel.activeCampaigns) { campaign in
                                    NavigationLink(destination: CampaignDetailView(campaign: campaign)) {
                                        DashboardCardView(
                                            iconName: "megaphone.fill",
                                            title: campaign.companyName ?? "Company",
                                            subtitle: campaign.name,
                                            content: campaign.formattedDateRange,
                                            subContent: "Earned: \(viewModel.formattedMonthlyEarnings)"
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }

                        // Messages
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Messages")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)

                            NavigationLink(destination: InboxView(userId: authService.userId ?? 0)) {
                                DashboardCardView(
                                    iconName: "envelope.fill",
                                    title: viewModel.unreadMessageCount > 0
                                        ? "\(viewModel.unreadMessageCount) new message\(viewModel.unreadMessageCount == 1 ? "" : "s")"
                                        : "No new messages",
                                    subtitle: "Inbox",
                                    content: viewModel.unreadMessageCount > 0
                                        ? "Tap to read your messages"
                                        : "You're all caught up",
                                    subContent: nil
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }


                        Spacer().frame(height: 80)
                    }
                    .padding(20)
                }
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
        .onReceive(NotificationCenter.default.publisher(for: .rideCompleted)) { _ in
            Task { await viewModel.fetchDashboardData() }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}


struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(authService: AuthenticationService(), rideViewModel: RideViewModel(authService: AuthenticationService()))
    }
}
