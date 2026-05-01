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

    /// True when the driver has seen all available campaigns this session
    @Published var allCampaignsSeen = false

    /// IDs the driver already interacted with (skipped or applied) - survives refresh
    private var seenCampaignIds: Set<Int> = []

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

        // UC02: discovery must hide campaigns the driver already applied to
        // (any status, including DECLINED) per the postcondition that
        // "applied" campaigns are not offered again. We refuse to populate
        // the swipe deck if we cannot reliably determine that set, otherwise
        // a network blip would silently turn the deck into a fresh list of
        // campaigns the driver has already been declined for.
        guard await fetchAppliedCampaignIds() else {
            self.errorMessage = "Couldn't load your application history. Pull to retry."
            self.campaigns = []
            return
        }

        do {
            let endpoint = Endpoint(path: "api/campaigns", queryItems: [
                URLQueryItem(name: "status", value: "RECRUITING")
            ])
            var fetchedCampaigns: [Campaign] = try await api.send(endpoint)
            await resolveCompanyNames(&fetchedCampaigns)
            let unseen = fetchedCampaigns.filter { !seenCampaignIds.contains($0.id) }
            self.campaigns = unseen
            self.skippedCampaigns = []
            self.allCampaignsSeen = unseen.isEmpty && !fetchedCampaigns.isEmpty
        } catch {
            self.errorMessage = error.localizedDescription
            self.campaigns = []
        }
    }

    private func fetchAppliedCampaignIds() async -> Bool {
        do {
            let endpoint = Endpoint(path: "api/campaigns/driver/\(driverId)/applications")
            let apps: [ApplicationWithCampaign] = try await api.send(endpoint)
            for app in apps {
                seenCampaignIds.insert(app.campaignId)
            }
            return true
        } catch {
            return false
        }
    }

    private func resolveCompanyNames(_ campaigns: inout [Campaign]) async {
        let uniqueIds = Set(campaigns.map { $0.companyId })
        var nameMap: [Int: String] = [:]
        for companyId in uniqueIds {
            do {
                let endpoint = Endpoint(path: "api/companies/\(companyId)")
                let company: Company = try await api.send(endpoint)
                nameMap[companyId] = company.name
            } catch {
                nameMap[companyId] = "Company"
            }
        }
        for i in campaigns.indices {
            campaigns[i].companyName = nameMap[campaigns[i].companyId]
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
            seenCampaignIds.insert(campaign.id)
            applySuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.applySuccess = false
            }
        } catch let error as NetworkError {
            removeCard(campaign)
            seenCampaignIds.insert(campaign.id)
            if case .serverError(let details) = error,
               details.internalCode == 3007 || details.internalCode == 3008 {
                errorMessage = details.message
            } else {
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Skip a campaign (swipe left) - pushes it onto the undo stack
    func skipCampaign(_ campaign: Campaign) {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else { return }
        campaigns.remove(at: index)
        skippedCampaigns.append(campaign)
        seenCampaignIds.insert(campaign.id)
    }

    /// Undo the last skip - pops from the undo stack and re-inserts at the front
    func undoLastSkip() {
        guard let lastSkipped = skippedCampaigns.popLast() else { return }
        campaigns.insert(lastSkipped, at: 0)
    }

    func removeCard(_ campaign: Campaign) {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else { return }
        campaigns.remove(at: index)
    }
}
