import Foundation

@MainActor
class CompanyHomePageViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: APIClientProtocol
    private let companyId: Int

    init(companyId: Int, api: APIClientProtocol = APIClient.shared) {
        self.companyId = companyId
        self.api = api
    }

    func fetchCampaigns() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let endpoint = Endpoint(path: "api/campaigns")
            let allCampaigns: [Campaign] = try await api.send(endpoint)
            self.campaigns = allCampaigns.filter { $0.companyId == companyId }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
