import SwiftUI

@MainActor
class DriverViewModel: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var driverId: Int?
    let campaignServiceBase = "http://localhost:8082"

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

    func applyToCampaign(campaignId: Int) async {
        guard let driverId = driverId else { return }
        guard let url = URL(string: "\(campaignServiceBase)/campaigns/\(campaignId)/apply?driverId=\(driverId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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