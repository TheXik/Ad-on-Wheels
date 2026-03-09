import SwiftUI

@MainActor
class BrowseViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var applySuccess = false

    private let api: APIClientProtocol
    private let driverId: Int

    init(driverId: Int, api: APIClientProtocol = APIClient.shared) {
        self.driverId = driverId
        self.api = api
    }

    func loadCampaigns() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let endpoint = Endpoint(path: "api/campaigns")
            let fetchedCampaigns: [Campaign] = try await api.send(endpoint)
            self.campaigns = fetchedCampaigns
        } catch {
            self.errorMessage = error.localizedDescription
            self.campaigns = []
        }
    }

    func applyToCampaign(_ campaign: Campaign) async {
        do {
            let endpoint = Endpoint(
                path: "api/campaigns/\(campaign.id)/apply",
                method: .post,
                queryItems: [URLQueryItem(name: "driverId", value: String(driverId))]
            )
            let _: Application = try await api.send(endpoint)
            removeCard(campaign)
            applySuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.applySuccess = false
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeCard(_ campaign: Campaign) {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else { return }
        campaigns.remove(at: index)
    }
}
