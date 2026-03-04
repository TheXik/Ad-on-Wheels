import SwiftUI

@MainActor
class BrowseViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api: APIClientProtocol
    
    init(api: APIClientProtocol = APIClient.shared) {
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
            // Fallback to empty list on error
            self.campaigns = []
        }
    }
    
    func removeCard(_ campaign: Campaign) {
        guard let index = campaigns.firstIndex(where: { $0.id == campaign.id }) else { return }
        campaigns.remove(at: index)
    }
}
