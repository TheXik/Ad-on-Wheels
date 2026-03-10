import SwiftUI

struct CompanyStatsView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel: CompanyHomePageViewModel
    @State private var selectedCampaignIndex = 0

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(authService: AuthenticationService) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: CompanyHomePageViewModel(companyId: authService.userId ?? 0))
    }

    var selectedCampaign: Campaign? {
        guard !viewModel.campaigns.isEmpty else { return nil }
        if selectedCampaignIndex < 0 { return nil }
        let index = min(selectedCampaignIndex, viewModel.campaigns.count - 1)
        return viewModel.campaigns[index]
    }

    var statsSource: [Campaign] {
        if let campaign = selectedCampaign {
            return [campaign]
        }
        return viewModel.campaigns
    }

    var totalReach: Int {
        statsSource.compactMap { $0.estimatedReach }.reduce(0, +)
    }

    var totalSpent: Double {
        statsSource.reduce(0) { $0 + $1.budget }
    }

    var totalDrivers: Int {
        statsSource.reduce(0) { $0 + $1.maxDrivers }
    }

    var avgDriverDistance: Int {
        totalDrivers > 0 ? 156 : 0
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Statistics")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 8)

                campaignPicker

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    statBox(title: "Total Reach", value: formattedNumber(totalReach), subtitle: "views", color: .purple)
                    statBox(title: "Avg. Distance", value: "\(avgDriverDistance)", subtitle: "km/month", color: .green)
                    statBox(title: "Total Spent", value: String(format: "€%.0f", totalSpent), subtitle: nil, color: .orange)
                    statBox(title: "Drivers Hired", value: "\(totalDrivers)", subtitle: nil, color: brandBlue)
                }

                HStack(spacing: 12) {
                    weeklyBarChart
                    budgetConsumptionChart
                }
                .frame(height: 170)

                driverPerformanceSnapshot
            }
            .padding(.horizontal)
            .padding(.bottom, 80)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .task {
            await viewModel.fetchCampaigns()
        }
    }

    var campaignPicker: some View {
        Menu {
            Button("All Campaigns") { selectedCampaignIndex = -1 }
            ForEach(Array(viewModel.campaigns.enumerated()), id: \.element.id) { index, campaign in
                Button(campaign.name) { selectedCampaignIndex = index }
            }
        } label: {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(brandBlue)
                Text(selectedCampaignIndex < 0 ? "All Campaigns" : (selectedCampaign?.name ?? "Select Campaign"))
                    .foregroundColor(.primary)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }

    func statBox(title: String, value: String, subtitle: String?, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(value.prefix(1))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                )

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    var weeklyBarChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Views")
                .font(.caption)
                .foregroundColor(.secondary)

            let days = ["M", "T", "W", "T", "F", "S", "S"]
            let values: [CGFloat] = [0.4, 0.7, 0.5, 0.85, 0.6, 0.3, 0.5]

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(zip(days.indices, days)), id: \.0) { index, day in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(brandBlue.opacity(index == 3 ? 1.0 : 0.5))
                            .frame(width: 14, height: values[index] * 70)
                        Text(day)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    var budgetConsumptionChart: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: 0.84)
                    .stroke(brandBlue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("84%")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("used")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80, height: 80)

            Text("Budget")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    var driverPerformanceSnapshot: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Top Drivers")
                .font(.headline)

            ForEach(Array(sampleDrivers.enumerated()), id: \.element.name) { index, driver in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(driverColor(index).opacity(0.12))
                            .frame(width: 36, height: 36)
                        Text(String(driver.name.prefix(1)))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(driverColor(index))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(driver.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(driver.car)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("\(driver.km) km")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    func driverColor(_ index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange]
        return colors[index % colors.count]
    }

    func formattedNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    var sampleDrivers: [(name: String, car: String, km: Int)] {
        [
            ("M. Horváth", "Škoda Octavia", 178),
            ("P. Tóth", "VW Golf", 162),
            ("L. Szalai", "Ford Focus", 154)
        ]
    }
}
