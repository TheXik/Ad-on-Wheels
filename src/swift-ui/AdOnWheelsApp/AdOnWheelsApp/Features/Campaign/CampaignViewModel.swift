import SwiftUI
import Combine

struct ApplicationWithDriver: Identifiable {
    let id: Int
    let campaignId: Int
    let campaignName: String
    let status: String
    let driver: Driver
}

@MainActor
class CampaignViewModel: ObservableObject {
    @Published var role: UserRole = .driver
    @Published var campaigns: [Campaign] = []
    @Published var applications: [Application] = []
    @Published var drivers: [Driver] = []
    @Published var companies: [Company] = []
    @Published var selectedDriver: Driver? = nil
    @Published var driverId: Int? = nil
    @Published var selectedCompanyId: Int? = nil

    // New: Joined application+driver info for company view
    @Published var appliedApplicationsWithDriver: [ApplicationWithDriver] = []
    @Published var acceptedApplicationsWithDriver: [ApplicationWithDriver] = []

    var isDriverLoggedIn: Bool {
        driverId != nil
    }
    var isCompanyLoggedIn: Bool {
        selectedCompanyId != nil
    }

    // MARK: - Networking
    let campaignServiceBase = "http://localhost:8082"
    let driverServiceBase = "http://localhost:8081"
    let companyServiceBase = "http://localhost:8083" 

    func loginDriver(with id: Int) {
        driverId = id
    }
    func loginCompany(with id: Int) {
        selectedCompanyId = id
    }

    func fetchDrivers() {
        guard let url = URL(string: "\(driverServiceBase)/drivers") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let drivers = try JSONDecoder().decode([Driver].self, from: data)
                DispatchQueue.main.async {
                    self.drivers = drivers
                }
            } catch {
                print("Error fetching drivers: \(error)")
            }
        }
    }

    func fetchCompanies() {
        guard let url = URL(string: "\(companyServiceBase)/companies") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let companies = try JSONDecoder().decode([Company].self, from: data)
                DispatchQueue.main.async {
                    self.companies = companies
                }
            } catch {
                print("Error fetching companies: \(error)")
            }
        }
    }

    // Updated: Fetch applications for company and join with driver and campaign name
    func fetchCompanyApplicationsWithDrivers() {
        guard let companyId = selectedCompanyId else { return }
        guard let url = URL(string: "\(campaignServiceBase)/campaigns/\(companyId)/applications") else { return }
        Task {
            do {
                // Fetch campaigns first for lookup
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
                DispatchQueue.main.async {
                    self.appliedApplicationsWithDriver = applied
                    self.acceptedApplicationsWithDriver = accepted
                }
            } catch {
                print("Error fetching company applications: \(error)")
            }
        }
    }

    func fetchCampaigns() async {
        guard let url = URL(string: "\(campaignServiceBase)/campaigns") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fetchedCampaigns = try JSONDecoder().decode([Campaign].self, from: data)
            DispatchQueue.main.async {
                self.campaigns = fetchedCampaigns
            }
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

    func applyToCampaign(campaignId: Int) {
        guard let driverId = driverId else { return }
        guard let url = URL(string: "\(campaignServiceBase)/campaigns/\(campaignId)/apply?driverId=\(driverId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Applied to campaign \(campaignId)")
                }
            } catch {
                print("Error applying to campaign: \(error)")
            }
        }
    }

    func fetchApplicationsForCompany() {
        guard let companyId = selectedCompanyId else { return }
        guard let url = URL(string: "\(campaignServiceBase)/campaigns/\(companyId)/applications") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let applications = try JSONDecoder().decode([Application].self, from: data)
                DispatchQueue.main.async {
                    self.applications = applications
                }
            } catch {
                print("Error fetching applications: \(error)")
            }
        }
    }

    func acceptApplication(applicationId: Int) {
        guard let url = URL(string: "\(campaignServiceBase)/campaigns/applications/\(applicationId)/accept") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Accepted application \(applicationId)")
                    fetchApplicationsForCompany()
                }
            } catch {
                print("Error accepting application: \(error)")
            }
        }
    }

    func declineApplication(applicationId: Int) {
        guard let url = URL(string: "\(campaignServiceBase)/campaigns/applications/\(applicationId)/decline") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Declined application \(applicationId)")
                    fetchApplicationsForCompany()
                }
            } catch {
                print("Error declining application: \(error)")
            }
        }
    }
} 
