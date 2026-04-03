import SwiftUI

struct BrowseCardView: View {
    let campaign: Campaign

    private var cardColor: Color {
        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink]
        return colors[campaign.id % colors.count]
    }

    private var cardIcon: String {
        let icons = ["car.fill", "bolt.car.fill", "leaf.fill", "box.truck.fill", "megaphone.fill", "star.fill"]
        return icons[campaign.id % icons.count]
    }

    private var imageURLs: [URL] {
        campaign.resolvedImageUrls
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(radius: 5)

            VStack(spacing: 0) {
                if !imageURLs.isEmpty {
                    TabView {
                        ForEach(imageURLs, id: \.absoluteString) { url in
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    fallbackView
                                default:
                                    ProgressView()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(cardColor.opacity(0.05))
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 300)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                } else {
                    fallbackView
                        .frame(height: 300)
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(campaign.companyName ?? "Company")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(campaign.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    HStack {
                        Label(campaign.formattedDateRange, systemImage: "calendar")
                        Spacer()
                        Text(campaign.formattedBudget)
                            .fontWeight(.semibold)
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

    private var fallbackView: some View {
        ZStack {
            cardColor.opacity(0.1)
            Image(systemName: cardIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(cardColor)
        }
    }
}

struct BrowseCardView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseCardView(campaign: Campaign(
            id: 1, name: "Test Campaign", description: "This is a test campaign description",
            companyId: 1, startDate: "2025-03-01", endDate: "2025-06-30",
            budget: 20000, maxDrivers: 38, estimatedReach: 120000, status: "RECRUITING",
            imageUrls: nil))
            .padding()
            .background(Color.gray.opacity(0.2))
    }
}
