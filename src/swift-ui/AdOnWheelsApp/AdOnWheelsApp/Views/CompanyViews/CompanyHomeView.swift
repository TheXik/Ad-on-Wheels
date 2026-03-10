import SwiftUI

struct CompanyHomeView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel: CompanyHomePageViewModel

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(authService: AuthenticationService) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: CompanyHomePageViewModel(companyId: authService.userId ?? 0))
    }

    var activeCampaigns: [Campaign] {
        viewModel.campaigns.filter { $0.isActive }
    }

    var totalBudget: Double {
        viewModel.campaigns.reduce(0) { $0 + $1.budget }
    }

    var totalReach: Int {
        viewModel.campaigns.compactMap { $0.estimatedReach }.reduce(0, +)
    }

    var totalDrivers: Int {
        viewModel.campaigns.reduce(0) { $0 + $1.maxDrivers }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Company XYZ")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 8)

                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        quickStatCard(
                            icon: "megaphone.fill",
                            value: "\(activeCampaigns.count)",
                            label: "Active Campaigns",
                            color: brandBlue
                        )
                        quickStatCard(
                            icon: "person.2.fill",
                            value: "\(totalDrivers)",
                            label: "Total Drivers",
                            color: .green
                        )
                        quickStatCard(
                            icon: "eye.fill",
                            value: formattedReach(totalReach),
                            label: "Est. Reach",
                            color: .purple
                        )
                        quickStatCard(
                            icon: "dollarsign.circle.fill",
                            value: String(format: "€%.0f", totalBudget),
                            label: "Total Budget",
                            color: .orange
                        )
                    }

                    if !activeCampaigns.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Campaigns")
                                .font(.headline)

                            ForEach(activeCampaigns) { campaign in
                                activeCampaignRow(campaign)
                            }
                        }
                    }

                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 80)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .task {
            await viewModel.fetchCampaigns()
        }
    }

    func quickStatCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    func activeCampaignRow(_ campaign: Campaign) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(brandBlue.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(brandBlue)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(campaign.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(campaign.formattedDateRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(campaign.formattedBudget)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(brandBlue)
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
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
