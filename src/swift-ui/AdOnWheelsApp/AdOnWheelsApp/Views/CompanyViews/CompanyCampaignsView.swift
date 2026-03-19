import SwiftUI

struct CompanyCampaignsView: View {
    @ObservedObject var dashboard: CompanyDashboardViewModel
    @State private var showCreateSheet = false
    @State private var selectedFilter = 0

    var filteredCampaigns: [Campaign] {
        dashboard.campaigns.filter { campaign in
            selectedFilter == 0 ? campaign.isActive : !campaign.isActive
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("Campaigns")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Spacer()
                Button(action: { showCreateSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.accentBlue)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Picker("Filter", selection: $selectedFilter) {
                Text("Active").tag(0)
                Text("Past").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            if dashboard.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = dashboard.errorMessage {
                Spacer()
                errorState(error)
                Spacer()
            } else if filteredCampaigns.isEmpty {
                Spacer()
                emptyState
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredCampaigns) { campaign in
                            CampaignDetailCard(
                                campaign: campaign,
                                hiredCount: dashboard.applications
                                    .filter { $0.campaignId == campaign.id && $0.status.uppercased() == "ACCEPTED" }
                                    .count
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .padding(.bottom, 80)
                }
            }
        }
        .background(Color.pageBackground)
        .sheet(isPresented: $showCreateSheet) {
            CreateCampaignView(companyId: dashboard.companyId) {
                showCreateSheet = false
                Task { await dashboard.fetchCampaigns() }
            }
        }
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "megaphone")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.3))
            Text(selectedFilter == 0 ? "No active campaigns" : "No past campaigns")
                .font(.headline)
                .foregroundColor(.secondary)
            if selectedFilter == 0 {
                Text("Create your first campaign to\nstart attracting drivers.")
                    .font(.subheadline)
                    .foregroundColor(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                Button(action: { showCreateSheet = true }) {
                    Text("Create Campaign")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(Color.accentBlue)
                        .cornerRadius(12)
                }
                .padding(.top, 4)
            }
        }
    }

    func errorState(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await dashboard.fetchCampaigns() }
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.accentBlue)
        }
        .padding()
    }
}

struct CampaignDetailCard: View {
    let campaign: Campaign
    let hiredCount: Int

    var statusColor: Color {
        switch campaign.status {
        case "RECRUITING": return .blue
        case "ACTIVE": return .green
        case "PAUSED": return .orange
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(campaign.name)
                        .font(.headline)
                    Text(campaign.formattedDateRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(campaign.status.capitalized)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor.opacity(0.1))
                    .clipShape(Capsule())
            }

            HStack(spacing: 0) {
                campaignMetric(icon: "person.2", value: "\(hiredCount)/\(campaign.maxDrivers)", label: "Drivers")
                Spacer()
                campaignMetric(icon: "eye", value: campaign.formattedReach, label: "Reach")
                Spacer()
                campaignMetric(icon: "eurosign.circle", value: campaign.formattedBudget, label: "Budget")
            }

            if campaign.maxDrivers > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Driver slots")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(hiredCount)/\(campaign.maxDrivers)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(statusColor)
                                .frame(width: geo.size.width * CGFloat(min(Double(hiredCount) / Double(campaign.maxDrivers), 1.0)), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    func campaignMetric(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(value)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundColor(.primary)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}
