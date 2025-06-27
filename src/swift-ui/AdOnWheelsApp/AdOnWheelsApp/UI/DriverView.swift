import SwiftUI

struct DriverView: View {
    @StateObject var viewModel: DriverViewModel

    var body: some View {
        VStack {
            Button("Logout") {
                viewModel.driverId = nil
            }
            .buttonStyle(.bordered)
            .padding(.bottom)
            List(viewModel.campaigns) { campaign in
                VStack(alignment: .leading) {
                    Text(campaign.name).font(.headline)
                    Text(campaign.description).font(.subheadline)
                    Button("Apply") {
                        Task {
                            await viewModel.applyToCampaign(campaignId: campaign.id)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.vertical, 4)
            }
            .onAppear {
                Task {
                    await viewModel.fetchCampaigns()
                }
            }
        }
    }
}
