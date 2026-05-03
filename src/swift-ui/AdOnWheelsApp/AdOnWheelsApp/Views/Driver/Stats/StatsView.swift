import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel
    @State private var selectedPeriod = 0

    private let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    private let cardBackground = Color(UIColor.secondarySystemGroupedBackground)

    init(authService: AuthenticationService) {
        _viewModel = StateObject(wrappedValue: StatsViewModel(authService: authService))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    summaryHeader

                    if viewModel.isLoading {
                        ProgressView("Loading statistics...")
                            .padding(.vertical, 40)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        statCards
                        earningsChart
                        recentRidesSection
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task { await viewModel.fetchStats() }
            }
            .refreshable {
                await viewModel.fetchStats()
            }
        }
    }

    private var summaryHeader: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(selectedPeriod == 0 ? "This Week" : "This Month")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(viewModel.formattedEarnings(for: selectedPeriod))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.top, 8)

            Picker("Period", selection: $selectedPeriod) {
                Text("Weekly").tag(0)
                Text("Monthly").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 40)
        }
        .padding()
    }

    private var statCards: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            StatCard(
                icon: "eurosign.circle.fill",
                iconColor: .green,
                value: String(format: "€%.2f", viewModel.totalEarnings),
                label: "Total Earnings"
            )
            StatCard(
                icon: "road.lanes",
                iconColor: brandBlue,
                value: viewModel.formattedDistance(for: selectedPeriod),
                label: selectedPeriod == 0 ? "Weekly Distance" : "Monthly Distance"
            )
            StatCard(
                icon: "gauge.medium",
                iconColor: .orange,
                value: String(format: "%.1f km/h", viewModel.averageSpeed),
                label: "Avg Speed"
            )
            StatCard(
                icon: "car.fill",
                iconColor: .purple,
                value: "\(viewModel.totalRides)",
                label: "Total Rides"
            )
        }
        .padding(.horizontal)
    }

    private var earningsChart: some View {
        let days = selectedPeriod == 0 ? 7 : 30
        return VStack(alignment: .leading, spacing: 12) {
            Text(selectedPeriod == 0 ? "Last 7 Days" : "Last 30 Days")
                .font(.headline)
                .foregroundColor(.primary)

            EarningsBarChart(
                dailyEarnings: viewModel.dailyEarnings(days),
                daysShown: days,
                brandBlue: brandBlue
            )
        }
        .padding()
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var recentRidesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(viewModel.totalRides) rides")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            if viewModel.recentRides.isEmpty {
                emptyRidesView
            } else {
                ridesList
            }
        }
    }

    private var emptyRidesView: some View {
        VStack(spacing: 10) {
            Image(systemName: "car.fill")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            Text("No rides yet")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("Complete a ride to see your activity here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var ridesList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.recentRides) { ride in
                NavigationLink(destination: RideDetailView(ride: ride)) {
                    RideRow(ride: ride)
                }

                if ride.id != viewModel.recentRides.last?.id {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

private struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct EarningsBarChart: View {
    let dailyEarnings: [Double]
    let daysShown: Int
    let brandBlue: Color

    private var maxEarning: Double {
        max(dailyEarnings.max() ?? 1, 1)
    }

    private var hasAnyEarnings: Bool {
        dailyEarnings.contains(where: { $0 > 0 })
    }

    // Bucket order is oldest → today; the last bucket is always today.
    private var todayIndex: Int { daysShown - 1 }

    private var showPerBarPriceLabels: Bool { daysShown <= 7 }

    private var barSpacing: CGFloat { daysShown <= 7 ? 10 : 2 }

    var body: some View {
        if hasAnyEarnings {
            barChart
        } else {
            emptyState
        }
    }

    private var barChart: some View {
        HStack(alignment: .bottom, spacing: barSpacing) {
            ForEach(0..<daysShown, id: \.self) { index in
                VStack(spacing: 6) {
                    Spacer(minLength: 0)

                    if showPerBarPriceLabels && dailyEarnings[index] > 0 {
                        Text(String(format: "€%.2f", dailyEarnings[index]))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    RoundedRectangle(cornerRadius: daysShown <= 7 ? 5 : 2)
                        .fill(brandBlue.opacity(index == todayIndex ? 1.0 : 0.3))
                        .frame(
                            height: dailyEarnings[index] > 0
                                ? max(10, CGFloat(dailyEarnings[index] / maxEarning) * 90)
                                : 2
                        )

                    Text(label(for: index))
                        .font(.system(size: daysShown <= 7 ? 11 : 9,
                                      weight: index == todayIndex ? .bold : .regular))
                        .foregroundColor(index == todayIndex ? .primary : .secondary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 140)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 28))
                .foregroundColor(.secondary)
            Text("No verified rides in the last \(daysShown) days")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
    }

    private func label(for index: Int) -> String {
        let daysAgo = todayIndex - index
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        let formatter = DateFormatter()
        if daysShown <= 7 {
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        }
        // 30-day view: only label every 5th bar + today, so axis is readable.
        if index == todayIndex || daysAgo % 5 == 0 {
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        }
        return ""
    }
}

private struct RideRow: View {
    let ride: Ride

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "car.fill")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 36, height: 36)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(ride.displayTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text("\(ride.formattedDuration) · \(ride.formattedDistance)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(ride.formattedEarnings)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(authService: AuthenticationService())
    }
}
