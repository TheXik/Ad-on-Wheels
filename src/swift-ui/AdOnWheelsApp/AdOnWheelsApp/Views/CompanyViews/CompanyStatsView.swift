import SwiftUI

struct CompanyStatsView: View {
    @ObservedObject var dashboard: CompanyDashboardViewModel
    @State private var selectedCampaignIndex = -1
    @State private var showShareSheet = false

    var selectedCampaign: Campaign? {
        guard !dashboard.campaigns.isEmpty, selectedCampaignIndex >= 0 else { return nil }
        let index = min(selectedCampaignIndex, dashboard.campaigns.count - 1)
        return dashboard.campaigns[index]
    }

    var statsSource: [Campaign] {
        if let campaign = selectedCampaign { return [campaign] }
        return dashboard.campaigns
    }

    var filteredApplications: [ApplicationWithDriver] {
        if let campaign = selectedCampaign {
            return dashboard.applications.filter { $0.campaignId == campaign.id }
        }
        return dashboard.applications
    }

    var totalReach: Int {
        statsSource.compactMap { $0.estimatedReach }.reduce(0, +)
    }

    var totalBudget: Double {
        statsSource.reduce(0) { $0 + $1.budget }
    }

    var driversHired: Int {
        filteredApplications.filter { $0.status.uppercased() == "ACCEPTED" }.count
    }

    var totalDriverSlots: Int {
        statsSource.reduce(0) { $0 + $1.maxDrivers }
    }

    var driverFillRate: Double {
        guard totalDriverSlots > 0 else { return 0 }
        return Double(driversHired) / Double(totalDriverSlots)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Text("Statistics")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Spacer()
                    if !dashboard.campaigns.isEmpty {
                        Button(action: {
                            Task {
                                if let campaign = selectedCampaign {
                                    await dashboard.exportCampaignCSV(campaignId: campaign.id)
                                } else {
                                    await dashboard.exportAllCampaignsCSV()
                                }
                            }
                        }) {
                            if dashboard.isExporting {
                                ProgressView()
                                    .frame(width: 34, height: 34)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 34, height: 34)
                                    .background(Color.accentBlue)
                                    .clipShape(Circle())
                            }
                        }
                        .disabled(dashboard.isExporting)
                    }
                }
                .padding(.top, 12)

                campaignPicker

                if dashboard.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if dashboard.campaigns.isEmpty {
                    emptyState
                } else {
                    overviewCards
                    chartsRow
                    topDriversSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Color.pageBackground)
        .refreshable {
            await dashboard.loadAll()
        }
        .onChange(of: dashboard.campaigns.count) { _, _ in
            // Reset selection when the campaigns list changes (e.g. after a delete)
            // so the picker doesn't silently snap to a different campaign at the
            // same index.
            selectedCampaignIndex = -1
        }
        .onChange(of: dashboard.exportedFileURL) { _, url in
            if url != nil {
                showShareSheet = true
            }
        }
        .sheet(isPresented: $showShareSheet, onDismiss: {
            dashboard.exportedFileURL = nil
        }) {
            if let fileURL = dashboard.exportedFileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
    }

    var campaignPicker: some View {
        Menu {
            Button {
                selectedCampaignIndex = -1
            } label: {
                if selectedCampaignIndex < 0 {
                    Label("All Campaigns", systemImage: "checkmark")
                } else {
                    Text("All Campaigns")
                }
            }
            Divider()
            ForEach(Array(dashboard.campaigns.enumerated()), id: \.element.id) { index, campaign in
                Button {
                    selectedCampaignIndex = index
                } label: {
                    if selectedCampaignIndex == index {
                        Label(campaign.name, systemImage: "checkmark")
                    } else {
                        Text(campaign.name)
                    }
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .foregroundColor(.accentBlue)
                Text(selectedCampaignIndex < 0 ? "All Campaigns" : (selectedCampaign?.name ?? "Select Campaign"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(Color.cardBackground)
            .cornerRadius(14)
        }
    }

    var overviewCards: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            CompanyStatCard(
                icon: "road.lanes",
                value: String(format: "%.1f km", dashboard.totalKmDriven),
                label: "Km Driven",
                iconColor: .purple
            )
            CompanyStatCard(
                icon: "person.2.fill",
                value: "\(driversHired) / \(totalDriverSlots)",
                label: "Drivers Hired",
                iconColor: .green
            )
            CompanyStatCard(
                icon: "car.fill",
                value: "\(dashboard.totalCampaignRides)",
                label: "Total Rides",
                iconColor: .orange
            )
            CompanyStatCard(
                icon: "chart.bar.fill",
                value: "\(statsSource.count)",
                label: "Campaigns",
                iconColor: .accentBlue
            )
        }
    }

    var chartsRow: some View {
        HStack(spacing: 14) {
            driverFillChart
            campaignBreakdownChart
        }
        .frame(height: 180)
    }

    var driverFillChart: some View {
        VStack(spacing: 12) {
            Text("Driver Fill Rate")
                .font(.caption)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.12), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(driverFillRate))
                    .stroke(
                        driverFillRate > 0.7 ? Color.green : (driverFillRate > 0.3 ? Color.accentBlue : Color.orange),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: driverFillRate)
                VStack(spacing: 2) {
                    Text("\(Int(driverFillRate * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("filled")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 80, height: 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    var campaignBreakdownChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Campaign Status")
                .font(.caption)
                .foregroundColor(.secondary)

            if dashboard.campaignStatusBreakdown.isEmpty {
                Spacer()
                Text("No data")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                VStack(spacing: 10) {
                    ForEach(dashboard.campaignStatusBreakdown, id: \.label) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(colorFor(item.color))
                                .frame(width: 8, height: 8)
                            Text(item.label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(item.count)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    var topDriversSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hired Drivers")
                .font(.title3)
                .fontWeight(.bold)

            if dashboard.topDrivers.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "person.2.slash")
                            .font(.title2)
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No hired drivers yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(Array(dashboard.topDrivers.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(driverAvatarColor(index).opacity(0.12))
                                .frame(width: 40, height: 40)
                            Text(String(item.driver.name.prefix(1)).uppercased())
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(driverAvatarColor(index))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.driver.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(item.campaignName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text(item.driver.vehicleDisplayName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    if index < dashboard.topDrivers.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 44))
                .foregroundColor(.secondary.opacity(0.4))
            Text("No statistics yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Create your first campaign to\nstart seeing statistics here.")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    func formattedNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    func colorFor(_ name: String) -> Color {
        switch name {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "gray": return .gray
        default: return .secondary
        }
    }

    func driverAvatarColor(_ index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .purple, .orange, .pink]
        return colors[index % colors.count]
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
