import SwiftUI

struct BrowseCardView: View {
    let campaign: AdCampaign
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image / Color
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 5)
            
            VStack(spacing: 0) {
                // Image Area
                ZStack {
                    campaign.color.opacity(0.1)
                    Image(systemName: campaign.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(campaign.color)
                }
                .frame(height: 300)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                
                // Details Area
                VStack(alignment: .leading, spacing: 10) {
                    Text(campaign.companyName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(campaign.campaignTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    HStack {
                        Label(campaign.duration, systemImage: "clock")
                        Spacer()
                        Label(campaign.reward, systemImage: "eurosign.circle")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text("Basic info about company and about duration of the promotion...")
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                        .padding(.top, 5)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            }
        }
        .frame(height: 500)
        .padding()
    }
}

struct BrowseCardView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseCardView(campaign: AdCampaign(companyName: "Test Company", campaignTitle: "Test Campaign", duration: "Now", reward: "100", imageName: "car", color: .blue))
            .padding()
            .background(Color.gray.opacity(0.2))
    }
}
