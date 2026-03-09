import SwiftUI

struct BrowseCardView: View {
    let campaign: Campaign
    
    // Generate a color based on campaign ID for visual variety
    private var cardColor: Color {
        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink]
        return colors[campaign.id % colors.count]
    }
    
    // Generate an icon based on campaign ID
    private var cardIcon: String {
        let icons = ["car.fill", "bolt.car.fill", "leaf.fill", "box.truck.fill", "megaphone.fill", "star.fill"]
        return icons[campaign.id % icons.count]
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image / Color
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(radius: 5)
            
            VStack(spacing: 0) {
                // Image Area
                ZStack {
                    cardColor.opacity(0.1)
                    Image(systemName: cardIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(cardColor)
                }
                .frame(height: 300)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                
                // Details Area
                VStack(alignment: .leading, spacing: 10) {
                    Text("Company #\(campaign.companyId)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(campaign.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Label("Active", systemImage: "clock")
                        Spacer()
                        Label("Apply Now", systemImage: "hand.raised")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text(campaign.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                        .padding(.top, 5)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            }
        }
        .frame(height: 500)
        .padding()
    }
}

struct BrowseCardView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseCardView(campaign: Campaign(id: 1, name: "Test Campaign", description: "This is a test campaign description", companyId: 1))
            .padding()
            .background(Color.gray.opacity(0.2))
    }
}
