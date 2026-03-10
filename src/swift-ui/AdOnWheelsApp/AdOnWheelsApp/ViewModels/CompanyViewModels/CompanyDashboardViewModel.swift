import Foundation

@MainActor
class CompanyDashboardViewModel: ObservableObject {
    @Published var company: Company?
    @Published var campaigns: [Campaign] = []
    @Published var applications: [ApplicationWithDriver] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var actionInProgress: Int?

    private let api: APIClientProtocol
    let companyId: Int

    init(companyId: Int, api: APIClientProtocol = APIClient.shared) {
        self.companyId = companyId
        self.api = api
    }

    var companyName: String {
        company?.name ?? "Company"
    }

    var activeCampaigns: [Campaign] {
        campaigns.filter { $0.isActive }
    }

    var completedCampaigns: [Campaign] {
        campaigns.filter { !$0.isActive }
    }

    var totalBudget: Double {
        campaigns.reduce(0) { $0 + $1.budget }
    }

    var activeBudget: Double {
        activeCampaigns.reduce(0) { $0 + $1.budget }
    }

    var totalReach: Int {
        campaigns.compactMap { $0.estimatedReach }.reduce(0, +)
    }

    var totalDriverSlots: Int {
        campaigns.reduce(0) { $0 + $1.maxDrivers }
    }

    var acceptedDriverCount: Int {
        applications.filter { $0.status.uppercased() == "ACCEPTED" }.count
    }

    var pendingApplicationCount: Int {
        applications.filter { $0.status.uppercased() == "APPLIED" }.count
    }

    var budgetUtilization: Double {
        guard totalBudget > 0 else { return 0 }
        return activeBudget / totalBudget
    }

    var campaignStatusBreakdown: [(label: String, count: Int, color: String)] {
        let statuses = ["RECRUITING", "ACTIVE", "PAUSED", "COMPLETED"]
        return statuses.compactMap { status in
            let count = campaigns.filter { $0.status == status }.count
            guard count > 0 else { return nil }
            let color: String
            switch status {
            case "RECRUITING": color = "blue"
            case "ACTIVE": color = "green"
            case "PAUSED": color = "orange"
            default: color = "gray"
            }
            return (label: status.capitalized, count: count, color: color)
        }
    }

    var topDrivers: [(driver: Driver, campaignName: String)] {
        applications
            .filter { $0.status.uppercased() == "ACCEPTED" }
            .prefix(5)
            .map { ($0.driver, $0.campaignName) }
    }

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        async let companyTask: () = fetchCompany()
        async let campaignsTask: () = fetchCampaigns()
        async let applicationsTask: () = fetchApplications()

        _ = await (companyTask, campaignsTask, applicationsTask)
    }

    func fetchCompany() async {
        do {
            let endpoint = Endpoint(path: "api/companies/\(companyId)")
            let fetched: Company = try await api.send(endpoint)
            self.company = fetched
        } catch {
            // Non-critical — we still have the ID
        }
    }

    func fetchCampaigns() async {
        do {
            let endpoint = Endpoint(path: "api/campaigns/company/\(companyId)")
            let fetched: [Campaign] = try await api.send(endpoint)
            self.campaigns = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func fetchApplications() async {
        do {
            let endpoint = Endpoint(path: "api/companies/\(companyId)/applications-with-drivers")
            let fetched: [ApplicationWithDriver] = try await api.send(endpoint)
            self.applications = fetched
        } catch {
            // Non-critical for home/stats
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
