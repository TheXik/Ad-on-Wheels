import SwiftUI

struct CompanyCampaignsView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel: CompanyHomePageViewModel
    @State private var showCreateSheet = false
    @State private var selectedFilter = 0

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(authService: AuthenticationService) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: CompanyHomePageViewModel(companyId: authService.userId ?? 0))
    }

    var filteredCampaigns: [Campaign] {
        viewModel.campaigns.filter { campaign in
            selectedFilter == 0 ? campaign.isActive : !campaign.isActive
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("Campaigns")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { showCreateSheet = true }) {
                    Image(systemName: "plus")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(brandBlue)
                        .frame(width: 36, height: 36)
                        .background(brandBlue.opacity(0.12))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top)

            Picker("Filter", selection: $selectedFilter) {
                Text("Active").tag(0)
                Text("Past").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 10)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 36))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await viewModel.fetchCampaigns() }
                    }
                    .font(.subheadline)
                    .foregroundColor(brandBlue)
                }
                .padding()
                Spacer()
            } else if filteredCampaigns.isEmpty {
                Spacer()
                VStack(spacing: 14) {
                    Image(systemName: "megaphone")
                        .font(.system(size: 44))
                        .foregroundColor(.gray.opacity(0.4))
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
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(brandBlue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 4)
                    }
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredCampaigns) { campaign in
                            CampaignCardView(campaign: campaign)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .padding(.bottom, 70)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .task {
            await viewModel.fetchCampaigns()
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateCampaignView(companyId: authService.userId ?? 0) {
                showCreateSheet = false
                Task { await viewModel.fetchCampaigns() }
            }
        }
    }
}

struct CampaignCardView: View {
    let campaign: Campaign
    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

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
                VStack(alignment: .leading, spacing: 4) {
                    Text(campaign.name)
                        .font(.headline)
                    Text(campaign.formattedDateRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(campaign.status.capitalized)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(8)
            }

            HStack {
                Label("\(campaign.maxDrivers)", systemImage: "person.2")
                Spacer()
                Label(campaign.formattedReach, systemImage: "eye")
                Spacer()
                Text(campaign.formattedBudget)
                    .fontWeight(.semibold)
                    .foregroundColor(brandBlue)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}
