import SwiftUI

@MainActor
class BrowseViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var applySuccess = false

    /// Stack of skipped campaigns for undo (back arrow) functionality
    @Published private(set) var skippedCampaigns: [Campaign] = []

    /// Whether undo is available (at least one skipped campaign exists)
    var canUndo: Bool { !skippedCampaigns.isEmpty }

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
            let endpoint = Endpoint(path: "api/campaigns", queryItems: [
                URLQueryItem(name: "status", value: "RECRUITING")
            ])
            let fetchedCampaigns: [Campaign] = try await api.send(endpoint)
            self.campaigns = fetchedCampaigns
            self.skippedCampaigns = []
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

    /// Skip a campaign (swipe left) — pushes it onto the undo stack
    func skipCampaign(_ campaign: Campaign) {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else { return }
        campaigns.remove(at: index)
        skippedCampaigns.append(campaign)
    }

    /// Undo the last skip — pops from the undo stack and re-inserts at the front
    func undoLastSkip() {
        guard let lastSkipped = skippedCampaigns.popLast() else { return }
        campaigns.insert(lastSkipped, at: 0)
    }

    func removeCard(_ campaign: Campaign) {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else { return }
        campaigns.remove(at: index)
    }
}
