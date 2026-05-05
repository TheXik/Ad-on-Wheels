import SwiftUI

struct DashboardView: View {
    @ObservedObject var authService: AuthenticationService
    @ObservedObject var viewModel: DashboardViewModel
    @ObservedObject var rideViewModel: RideViewModel
    var onDeferredScanTap: () -> Void

    @State private var composeApp: ApplicationWithCampaign?

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        ZStack(alignment: .top) {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                DashboardHeaderView(viewModel: viewModel)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 10)

                        if rideViewModel.hasDeferredRideData && !rideViewModel.isRiding {
                            Button(action: onDeferredScanTap) {
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 50, height: 50)

                                        Image(systemName: "qrcode.viewfinder")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Forgot to Start a Ride?")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("\(rideViewModel.gpsBuffer.count) GPS points recorded - scan to log your ride")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Campaigns")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)

                            if viewModel.activeCampaigns.isEmpty {
                                DashboardCardView(
                                    iconName: "megaphone",
                                    title: "No active campaigns",
                                    subtitle: "Discover",
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

                        if !viewModel.myApplications.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("My Applications")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 4)

                                if viewModel.pendingApplicationCount > 1 {
                                    HStack(spacing: 6) {
                                        Image(systemName: "info.circle")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        Text("Apply to as many as you like — once accepted, the rest decline automatically.")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 4)
                                }

                                ForEach(viewModel.myApplications) { app in
                                    VStack(spacing: 0) {
                                        HStack(spacing: 15) {
                                            ZStack {
                                                Circle()
                                                    .fill(applicationColor(app.status).opacity(0.2))
                                                    .frame(width: 44, height: 44)
                                                Image(systemName: applicationIcon(app.status))
                                                    .foregroundColor(applicationColor(app.status))
                                            }

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(app.campaignName)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)
                                                Text(applicationLabel(app.status))
                                                    .font(.caption)
                                                    .foregroundColor(applicationColor(app.status))
                                            }

                                            Spacer()

                                            Text(applicationLabel(app.status))
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(applicationColor(app.status).opacity(0.15))
                                                .foregroundColor(applicationColor(app.status))
                                                .cornerRadius(8)
                                        }

                                        if app.status.uppercased() == "ACCEPTED" {
                                            Divider().padding(.top, 10)
                                            HStack(spacing: 12) {
                                                Text("You're in! Start driving to earn.")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                if app.companyId != nil {
                                                    Button(action: { composeApp = app }) {
                                                        HStack(spacing: 4) {
                                                            Image(systemName: "envelope")
                                                            Text("Message")
                                                        }
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.blue)
                                                    }
                                                }
                                            }
                                            .padding(.top, 8)
                                        } else if app.status.uppercased() == "APPLIED" {
                                            Divider().padding(.top, 10)
                                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    Task { await viewModel.withdrawApplication(app) }
                                                }) {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "arrow.uturn.backward")
                                                        Text("Withdraw")
                                                    }
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.red)
                                                }
                                            }
                                            .padding(.top, 8)
                                        }
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(16)
                                }
                            }
                        }

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
        .sheet(item: $composeApp) { app in
            ComposeMessageView(
                senderId: authService.userId ?? 0,
                senderRole: "DRIVER",
                recipientId: app.companyId ?? 0,
                recipientRole: "COMPANY",
                recipientName: app.campaignName,
                campaignId: app.campaignId,
                campaignName: app.campaignName
            )
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


private func applicationColor(_ status: String) -> Color {
    switch status.uppercased() {
    case "ACCEPTED": return .green
    case "DECLINED": return .red
    case "EXPIRED": return .gray
    default: return .orange
    }
}

private func applicationIcon(_ status: String) -> String {
    switch status.uppercased() {
    case "ACCEPTED": return "checkmark.circle.fill"
    case "DECLINED": return "xmark.circle.fill"
    case "EXPIRED": return "clock.badge.xmark.fill"
    default: return "clock.fill"
    }
}

private func applicationLabel(_ status: String) -> String {
    switch status.uppercased() {
    case "ACCEPTED": return "Accepted"
    case "DECLINED": return "Declined"
    case "EXPIRED": return "Campaign ended"
    default: return "Pending"
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let auth = AuthenticationService()
        DashboardView(authService: auth, viewModel: DashboardViewModel(authService: auth), rideViewModel: RideViewModel(authService: auth)) {}
    }
}
