import SwiftUI

struct CompanyHomeView: View {
    @ObservedObject var dashboard: CompanyDashboardViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                if dashboard.isLoading {
                    loadingPlaceholder
                } else {
                    statsGrid

                    if !dashboard.activeCampaigns.isEmpty {
                        activeCampaignsSection
                    }

                    if dashboard.pendingApplicationCount > 0 {
                        pendingBanner
                    }

                    if let error = dashboard.errorMessage {
                        errorBanner(error)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Color.pageBackground)
        .refreshable {
            await dashboard.loadAll()
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(dashboard.companyName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
        }
        .padding(.top, 12)
    }

    var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            CompanyStatCard(
                icon: "megaphone.fill",
                value: "\(dashboard.activeCampaigns.count)",
                label: "Active Campaigns",
                iconColor: .accentBlue
            )
            CompanyStatCard(
                icon: "person.2.fill",
                value: "\(dashboard.acceptedDriverCount)",
                label: "Hired Drivers",
                iconColor: .green
            )
            CompanyStatCard(
                icon: "eye.fill",
                value: formattedReach(dashboard.totalReach),
                label: "Est. Reach",
                iconColor: .purple
            )
            CompanyStatCard(
                icon: "eurosign.circle.fill",
                value: String(format: "€%.0f", dashboard.totalBudget),
                label: "Total Budget",
                iconColor: .orange
            )
        }
    }

    var activeCampaignsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Active Campaigns")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text("\(dashboard.activeCampaigns.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }

            ForEach(dashboard.activeCampaigns) { campaign in
                CampaignRow(campaign: campaign)
            }
        }
    }

    var pendingBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.badge.fill")
                .font(.title3)
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(dashboard.pendingApplicationCount) pending application\(dashboard.pendingApplicationCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Review driver applications")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
                )
        )
    }

    var loadingPlaceholder: some View {
        VStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .frame(height: 80)
            }
        }
        .redacted(reason: .placeholder)
    }

    func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(14)
    }

    func formattedReach(_ reach: Int) -> String {
        if reach >= 1_000_000 {
            return String(format: "%.1fM", Double(reach) / 1_000_000)
        } else if reach >= 1000 {
            return String(format: "%.1fK", Double(reach) / 1000)
        }
        return "\(reach)"
    }
}

struct CompanyStatCard: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)
                .padding(8)
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct CampaignRow: View {
    let campaign: Campaign

    var statusColor: Color {
        switch campaign.status {
        case "RECRUITING": return .blue
        case "ACTIVE": return .green
        case "PAUSED": return .orange
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(statusColor.opacity(0.1))
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "megaphone.fill")
                        .font(.system(size: 16))
                        .foregroundColor(statusColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(campaign.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                HStack(spacing: 8) {
                    Text(campaign.formattedDateRange)
                    Text("·")
                    Text("\(campaign.maxDrivers) drivers")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(campaign.formattedBudget)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.accentBlue)
                Text(campaign.status.capitalized)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(statusColor)
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}
