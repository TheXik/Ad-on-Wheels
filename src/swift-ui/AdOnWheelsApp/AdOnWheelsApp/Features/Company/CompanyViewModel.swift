import SwiftUI

@MainActor
class CompanyViewModel: ObservableObject {
    @Published var appliedApplicationsWithDriver: [ApplicationWithDriver] = []
    @Published var acceptedApplicationsWithDriver: [ApplicationWithDriver] = []
    @Published var selectedCompanyId: Int?
    @Published var campaigns: [Campaign] = []
    let campaignServiceBase = "http://localhost:8082"
    let driverServiceBase = "http://localhost:8081"

    func fetchCompanyApplicationsWithDrivers() async {
        guard let companyId = selectedCompanyId else { return }
        guard let url = URL(string: "\(campaignServiceBase)/campaigns/\(companyId)/applications") else { return }
        do {
            await fetchCampaigns()
            let (data, _) = try await URLSession.shared.data(from: url)
            let applications = try JSONDecoder().decode([Application].self, from: data)
            var applied: [ApplicationWithDriver] = []
            var accepted: [ApplicationWithDriver] = []
            for app in applications {
                if app.status == "applied" || app.status == "accepted" {
                    if let driver = try? await fetchDriverById(app.driverId),
                       let campaign = campaigns.first(where: { $0.id == app.campaignId }) {
                        let joined = ApplicationWithDriver(
                            id: app.id,
                            campaignId: app.campaignId,
                            campaignName: campaign.name,
                            status: app.status,
                            driver: driver
                        )
                        if app.status == "applied" {
                            applied.append(joined)
                        } else if app.status == "accepted" {
                            accepted.append(joined)
                        }
                    }
                }
            }
            self.appliedApplicationsWithDriver = applied
            self.acceptedApplicationsWithDriver = accepted
        } catch {
            print("Error fetching company applications: \(error)")
        }
    }

    func fetchCampaigns() async {
        guard let url = URL(string: "\(campaignServiceBase)/campaigns") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fetchedCampaigns = try JSONDecoder().decode([Campaign].self, from: data)
            self.campaigns = fetchedCampaigns
        } catch {
            print("Error fetching campaigns: \(error)")
        }
    }

    func fetchDriverById(_ id: Int) async throws -> Driver {
        guard let url = URL(string: "\(driverServiceBase)/drivers/\(id)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Driver.self, from: data)
    }

    func acceptApplication(applicationId: Int) async {
        guard let url = URL(string: "\(campaignServiceBase)/campaigns/applications/\(applicationId)/accept") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Accepted application \(applicationId)")
                await fetchCompanyApplicationsWithDrivers()
            }
        } catch {
            print("Error accepting application: \(error)")
        }
    }

    func declineApplication(applicationId: Int) async {
        guard let url = URL(string: "\(campaignServiceBase)/campaigns/applications/\(applicationId)/decline") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Declined application \(applicationId)")
                await fetchCompanyApplicationsWithDrivers()
            }
        } catch {
            print("Error declining application: \(error)")
        }
    }
} 