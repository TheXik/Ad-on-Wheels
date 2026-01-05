import SwiftUI

struct DashboardCardView: View {
    let iconName: String
    let title: String
    let subtitle: String?
    let content: String
    let subContent: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon Background
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue) // Accent color
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Header
                if let subtitle = subtitle {
                    Text(subtitle.uppercased())
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                }
                
                // Title
                Text(title)
                    .font(.body) // Slightly smaller than headline for better hierarchy
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // Content
                if let subContent = subContent {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(content)
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        Text(subContent)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.top, 2)
                    }
                } else {
                     Text(content)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer(minLength: 0)
            
            // Optional Chevron for interactivity hint
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// Preview Provider
struct DashboardCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
            VStack {
                DashboardCardView(
                    iconName: "megaphone",
                    title: "Firma XYZ",
                    subtitle: "Aktuálna Reklama",
                    content: "Trvanie: 14. 3. - 12. 4.",
                    subContent: "Odmena: 100€ / mesiac"
                )
                
                DashboardCardView(
                    iconName: "envelope",
                    title: "Nové podmienky pre apríl sú dostupné.",
                    subtitle: "Správy od firmy",
                    content: "Skontrolujte si prosím nové podmienky...",
                    subContent: nil
                )
            }
            .padding()
        }
    }
}
