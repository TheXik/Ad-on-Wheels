import Foundation

@MainActor
class CompanyApplicationsViewModel: ObservableObject {
    @Published var applications: [ApplicationWithDriver] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var actionInProgress: Int?

    private let api: APIClientProtocol
    private let companyId: Int

    init(companyId: Int, api: APIClientProtocol = APIClient.shared) {
        self.companyId = companyId
        self.api = api
    }

    func fetchApplications() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let endpoint = Endpoint(path: "api/companies/\(companyId)/applications-with-drivers")
            let fetched: [ApplicationWithDriver] = try await api.send(endpoint)
            self.applications = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func acceptApplication(_ applicationId: Int) async {
        actionInProgress = applicationId
        defer { actionInProgress = nil }

        do {
            let endpoint = Endpoint(
                path: "api/campaigns/applications/\(applicationId)/accept",
                method: .post
            )
            let _: Application = try await api.send(endpoint)
            if let idx = applications.firstIndex(where: { $0.id == applicationId }) {
                let old = applications[idx]
                applications[idx] = ApplicationWithDriver(
                    id: old.id, campaignId: old.campaignId,
                    campaignName: old.campaignName, status: "ACCEPTED", driver: old.driver
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func declineApplication(_ applicationId: Int) async {
        actionInProgress = applicationId
        defer { actionInProgress = nil }

        do {
            let endpoint = Endpoint(
                path: "api/campaigns/applications/\(applicationId)/decline",
                method: .post
            )
            let _: Application = try await api.send(endpoint)
            if let idx = applications.firstIndex(where: { $0.id == applicationId }) {
                let old = applications[idx]
                applications[idx] = ApplicationWithDriver(
                    id: old.id, campaignId: old.campaignId,
                    campaignName: old.campaignName, status: "DECLINED", driver: old.driver
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
