import SwiftUI

struct AdCampaign: Identifiable, Equatable {
    let id = UUID()
    let companyName: String
    let campaignTitle: String
    let duration: String
    let reward: String
    let imageName: String // Using system name or asset name
    let color: Color
}

class BrowseViewModel: ObservableObject {
    @Published var campaigns: [AdCampaign] = []
    
    init() {
        loadCampaigns()
    }
    
    func loadCampaigns() {
        // Mock Data just for now
        self.campaigns = [
            AdCampaign(companyName: "Firma XYZ", campaignTitle: "Brand Awareness Spring", duration: "14.3. - 12.4.", reward: "100€ / mesiac", imageName: "car.fill", color: .blue),
            AdCampaign(companyName: "Tech Corp", campaignTitle: "New Product Launch", duration: "01.5. - 30.5.", reward: "150€ / mesiac", imageName: "bolt.car.fill", color: .red),
            AdCampaign(companyName: "Eco Foods", campaignTitle: "Go Green Initiative", duration: "10.6. - 10.9.", reward: "120€ / mesiac", imageName: "leaf.fill", color: .green),
            AdCampaign(companyName: "City Moving", campaignTitle: "We move you", duration: "Permanent", reward: "200€ / mesiac", imageName: "box.truck.fill", color: .orange)
        ]
    }
    
    func removeCard(_ campaign: AdCampaign) {
        guard let index = campaigns.firstIndex(of: campaign) else { return }
        // In a real app, you might want to keep it in history or API
        campaigns.remove(at: index)
    }
}
