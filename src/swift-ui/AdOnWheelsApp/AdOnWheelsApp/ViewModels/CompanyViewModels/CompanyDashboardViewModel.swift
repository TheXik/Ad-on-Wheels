import Foundation

@MainActor
class CompanyDashboardViewModel: ObservableObject {
    @Published var company: Company?
    @Published var campaigns: [Campaign] = []
    @Published var applications: [ApplicationWithDriver] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var actionInProgress: Int?
    @Published var isExporting = false
    @Published var exportedFileURL: URL?
    @Published var campaignRideStats: [CampaignRideStat] = []

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

    var acceptedDriverCount: Int {
        applications.filter { $0.status.uppercased() == "ACCEPTED" }.count
    }

    var pendingApplicationCount: Int {
        applications.filter { $0.status.uppercased() == "APPLIED" }.count
    }

    var campaignStatusBreakdown: [(label: String, count: Int, color: String)] {
        let statuses = ["RECRUITING", "COMPLETED"]
        return statuses.compactMap { status in
            let count = campaigns.filter { $0.status == status }.count
            guard count > 0 else { return nil }
            let color: String
            switch status {
            case "RECRUITING": color = "blue"
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
        async let rideStatsTask: () = fetchCampaignRideStats()

        _ = await (companyTask, campaignsTask, applicationsTask, rideStatsTask)
    }

    func fetchCompany() async {
        do {
            let endpoint = Endpoint(path: "api/companies/\(companyId)")
            let fetched: Company = try await api.send(endpoint)
            self.company = fetched
        } catch {
            // Non-critical - we still have the ID
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

    func fetchCampaignRideStats() async {
        do {
            let endpoint = Endpoint(path: "api/companies/\(companyId)/campaign-stats")
            let fetched: [CampaignRideStat] = try await api.send(endpoint)
            self.campaignRideStats = fetched
        } catch {
            // Surface as a banner: with stats unavailable, "Km Driven" / "Total
            // Rides" / "Earnings Paid" all read zero, which would otherwise be
            // indistinguishable from an empty company.
            self.errorMessage = "Stats temporarily unavailable: \(error.localizedDescription)"
        }
    }

    var totalKmDriven: Double {
        campaignRideStats.reduce(0) { $0 + $1.rideStats.totalDistanceKm }
    }

    var totalCampaignRides: Int {
        campaignRideStats.reduce(0) { $0 + $1.rideStats.totalRides }
    }

    func deleteCampaign(_ campaignId: Int) async {
        do {
            let endpoint = Endpoint(path: "api/campaigns/\(campaignId)", method: .delete)
            try await api.send(endpoint)
            campaigns.removeAll { $0.id == campaignId }
            applications.removeAll { $0.campaignId == campaignId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func acceptApplication(_ applicationId: Int) async {
        actionInProgress = applicationId
        defer { actionInProgress = nil }
        do {
            let body = try JSONSerialization.data(withJSONObject: ["status": "ACCEPTED"])
            let endpoint = Endpoint(
                path: "api/campaigns/applications/\(applicationId)",
                method: .patch,
                body: body
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
            let body = try JSONSerialization.data(withJSONObject: ["status": "DECLINED"])
            let endpoint = Endpoint(
                path: "api/campaigns/applications/\(applicationId)",
                method: .patch,
                body: body
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


    /// Export a single campaign's stats as CSV.
    func exportCampaignCSV(campaignId: Int) async {
        isExporting = true
        defer { isExporting = false }
        do {
            let endpoint = Endpoint(
                path: "api/campaigns/\(campaignId)/export",
                headers: ["Accept": "text/csv"]
            )
            let data = try await api.sendRawData(endpoint)
            let filename = "campaign_\(campaignId)_stats.csv"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: url)
            exportedFileURL = url
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
        }
    }

    /// Export all campaigns for this company as enriched CSV (with ride stats).
    func exportAllCampaignsCSV() async {
        isExporting = true
        defer { isExporting = false }
        do {
            let endpoint = Endpoint(
                path: "api/companies/\(companyId)/export-csv",
                headers: ["Accept": "text/csv"]
            )
            let data = try await api.sendRawData(endpoint)
            let filename = "company_\(companyId)_campaigns.csv"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: url)
            exportedFileURL = url
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
        }
    }
}
