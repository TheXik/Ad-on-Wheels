import SwiftUI

@MainActor
class CompanyViewModel: ObservableObject {
    @Published var appliedApplicationsWithDriver: [ApplicationWithDriver] = []
    @Published var acceptedApplicationsWithDriver: [ApplicationWithDriver] = []
    @Published var selectedCompanyId: Int?
    @Published var campaigns: [Campaign] = []
    let apiBase = "http://localhost:8084/api"

    func fetchCompanyApplicationsWithDrivers() async {
        guard let companyId = selectedCompanyId else { return }
        guard let url = URL(string: "\(apiBase)/companies/\(companyId)/applications-with-drivers") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let applications = try JSONDecoder().decode([ApplicationWithDriver].self, from: data)
            self.appliedApplicationsWithDriver = applications.filter { $0.status == "applied" }
            self.acceptedApplicationsWithDriver = applications.filter { $0.status == "accepted" }
        } catch {
            print("Error fetching company applications: \(error)")
        }
    }

    func fetchCampaigns() async {
        guard let url = URL(string: "\(apiBase)/campaigns") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let fetchedCampaigns = try JSONDecoder().decode([Campaign].self, from: data)
            self.campaigns = fetchedCampaigns
        } catch {
            print("Error fetching campaigns: \(error)")
        }
    }

    func fetchDriverById(_ id: Int) async throws -> Driver {
        guard let url = URL(string: "\(apiBase)/drivers/\(id)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Driver.self, from: data)
    }

    func acceptApplication(applicationId: Int) async {
        guard let url = URL(string: "\(apiBase)/campaigns/applications/\(applicationId)/accept") else { return }
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
        guard let url = URL(string: "\(apiBase)/campaigns/applications/\(applicationId)/decline") else { return }
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
