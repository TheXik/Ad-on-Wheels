import SwiftUI

struct CompanyCampaignsView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel: CompanyHomePageViewModel
    @State private var showCreateSheet = false

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(authService: AuthenticationService) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: CompanyHomePageViewModel(companyId: authService.userId ?? 0))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("My Campaigns")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { showCreateSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(brandBlue)
                }
            }
            .padding(.horizontal)
            .padding(.top)

            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading campaigns...")
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await viewModel.fetchCampaigns() }
                    }
                }
                .padding()
                Spacer()
            } else if viewModel.campaigns.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "megaphone")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No campaigns yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Create your first campaign to start\nattracting drivers.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button(action: { showCreateSheet = true }) {
                        Text("Create Campaign")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(brandBlue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.campaigns) { campaign in
                            CampaignRowView(campaign: campaign)
                        }
                    }
                    .padding()
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

struct CampaignRowView: View {
    let campaign: Campaign

    private var cardColor: Color {
        let colors: [Color] = [.blue, .purple, .orange, .green, .pink, .red]
        return colors[campaign.id % colors.count]
    }

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(cardColor.opacity(0.15))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "megaphone.fill")
                        .foregroundColor(cardColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(campaign.name)
                    .font(.headline)
                Text(campaign.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}
