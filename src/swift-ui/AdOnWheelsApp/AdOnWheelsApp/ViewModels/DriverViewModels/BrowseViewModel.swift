import SwiftUI

@MainActor
class BrowseViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var applySuccess = false

    @Published private(set) var skippedCampaigns: [Campaign] = []
    var canUndo: Bool { !skippedCampaigns.isEmpty }

    @Published var allCampaignsSeen = false

    // Survives refresh so we don't show the same card twice in one session.
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

        // Bail out if we can't load the applied set — otherwise a network
        // blip would re-show campaigns the driver has already been declined for.
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
               [3002, 3003, 3007, 3008].contains(details.internalCode) {
                errorMessage = details.message
            } else {
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func skipCampaign(_ campaign: Campaign) {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else { return }
        campaigns.remove(at: index)
        skippedCampaigns.append(campaign)
        seenCampaignIds.insert(campaign.id)
    }

    func undoLastSkip() {
        guard let lastSkipped = skippedCampaigns.popLast() else { return }
        campaigns.insert(lastSkipped, at: 0)
    }

    func removeCard(_ campaign: Campaign) {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else { return }
        campaigns.remove(at: index)
    }
}
