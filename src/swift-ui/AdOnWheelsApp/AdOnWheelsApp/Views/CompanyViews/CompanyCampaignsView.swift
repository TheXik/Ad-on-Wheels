import SwiftUI

struct CompanyCampaignsView: View {
    @ObservedObject var dashboard: CompanyDashboardViewModel
    @State private var showCreateSheet = false
    @State private var selectedFilter = 0
    @State private var campaignToDelete: Campaign?

    private let filterOptions = ["All", "Recruiting", "Active", "Paused", "Completed"]

    var filteredCampaigns: [Campaign] {
        switch selectedFilter {
        case 1: return dashboard.campaigns.filter { $0.status == "RECRUITING" }
        case 2: return dashboard.campaigns.filter { $0.status == "ACTIVE" }
        case 3: return dashboard.campaigns.filter { $0.status == "PAUSED" }
        case 4: return dashboard.campaigns.filter { $0.status == "COMPLETED" }
        default: return dashboard.campaigns
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<filterOptions.count, id: \.self) { index in
                        Button(action: { selectedFilter = index }) {
                            Text(filterOptions[index])
                                .font(.subheadline)
                                .fontWeight(selectedFilter == index ? .semibold : .regular)
                                .foregroundColor(selectedFilter == index ? .white : .secondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedFilter == index ? Color.accentBlue : Color.gray.opacity(0.12))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
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
                                    .count,
                                onDelete: { campaignToDelete = campaign }
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
        .alert("Delete Campaign", isPresented: .constant(campaignToDelete != nil)) {
            Button("Cancel", role: .cancel) { campaignToDelete = nil }
            Button("Delete", role: .destructive) {
                if let campaign = campaignToDelete {
                    campaignToDelete = nil
                    Task { await dashboard.deleteCampaign(campaign.id) }
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(campaignToDelete?.name ?? "")\"? This cannot be undone.")
        }
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "megaphone")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.3))
            Text(selectedFilter == 0 ? "No campaigns yet" : "No \(filterOptions[selectedFilter].lowercased()) campaigns")
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
    var onDelete: (() -> Void)? = nil
    @State private var showCoverageSheet = false

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

            Button(action: { showCoverageSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "map")
                        .font(.system(size: 12, weight: .semibold))
                    Text("View coverage map")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.accentBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.accentBlue.opacity(0.08))
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .contextMenu {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Campaign", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showCoverageSheet) {
            CampaignCoverageView(campaign: campaign)
        }
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
