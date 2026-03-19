import SwiftUI

struct CampaignDetailView: View {
    let campaign: Campaign
    var onApply: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    private var cardColor: Color {
        let colors: [Color] = [.blue, .red, .green, .orange, .purple, .pink]
        return colors[campaign.id % colors.count]
    }

    private var cardIcon: String {
        let icons = ["car.fill", "bolt.car.fill", "leaf.fill", "box.truck.fill", "megaphone.fill", "star.fill"]
        return icons[campaign.id % icons.count]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle()
                        .fill(cardColor.opacity(0.1))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: cardIcon)
                                .resizable()
                                .scaledToFit()
                                .padding(60)
                                .foregroundColor(cardColor)
                        )

                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(campaign.companyName ?? "Company")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)

                            Text(campaign.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }

                        Divider()

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            DetailInfoBox(label: "Duration", value: campaign.formattedDateRange, icon: "calendar")
                            DetailInfoBox(label: "Budget", value: campaign.formattedBudget, icon: "dollarsign.circle")
                            DetailInfoBox(label: "Drivers", value: "\(campaign.maxDrivers)", icon: "person.2")
                            DetailInfoBox(label: "Est. Reach", value: campaign.formattedReach, icon: "eye")
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("About Campaign")
                                .font(.headline)
                            Text(campaign.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }

                        Spacer().frame(height: 20)

                        if let onApply {
                            Button(action: {
                                onApply()
                                dismiss()
                            }) {
                                Text("Apply Now")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(15)
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(25)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .offset(y: -30)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct DetailInfoBox: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct CampaignDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CampaignDetailView(
            campaign: Campaign(
                id: 1, name: "Test Campaign", description: "This is a test campaign with a longer description.",
                companyId: 1, startDate: "2025-03-01", endDate: "2025-06-30",
                budget: 20000, maxDrivers: 38, estimatedReach: 120000, status: "RECRUITING"),
            onApply: {}
        )
    }
}

