import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel: StatsViewModel
    @State private var selectedPeriod = 0 // 0: Weekly, 1: Monthly
    
    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    init(authService: AuthenticationService = AuthenticationService.shared) {
        _viewModel = StateObject(wrappedValue: StatsViewModel(authService: authService))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // Header / Date Selector
                    Picker("Period", selection: $selectedPeriod) {
                        Text("Weekly").tag(0)
                        Text("Monthly").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top)
                    
                    if viewModel.isLoading {
                        ProgressView("Loading statistics...")
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        // Main Summary Cards
                        HStack(spacing: 15) {
                            StatsSummaryCard(
                                title: "Total Earnings",
                                value: viewModel.formattedEarnings(for: selectedPeriod),
                                icon: "eurosign.circle.fill",
                                color: .green
                            )
                            StatsSummaryCard(
                                title: "Total Distance",
                                value: viewModel.formattedDistance(for: selectedPeriod),
                                icon: "speedometer",
                                color: brandBlue
                            )
                        }
                        .padding(.horizontal)
                        
                        // Additional stats
                        HStack(spacing: 15) {
                            StatsSummaryCard(
                                title: "Average Speed",
                                value: String(format: "%.1f km/h", viewModel.averageSpeed),
                                icon: "gauge",
                                color: .orange
                            )
                            StatsSummaryCard(
                                title: "Total Rides",
                                value: "\(viewModel.totalRides)",
                                icon: "car.fill",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                        
                        // Chart Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Earnings History (Last 7 Days)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            EarningsChartView(dailyEarnings: viewModel.dailyEarnings, brandBlue: brandBlue)
                                .padding(.horizontal)
                        }
                        
                        // Recent Rides List
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Recent Activity")
                                    .font(.headline)
                                Spacer()
                                Text("\(viewModel.totalRides) rides total")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            if viewModel.recentRides.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "car.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("No rides yet")
                                        .foregroundColor(.gray)
                                    Text("Start a ride to see your activity here")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.recentRides) { ride in
                                        RecentRideRowFromAPI(ride: ride)
                                        if ride.id != viewModel.recentRides.last?.id {
                                            Divider()
                                        }
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitle("Statistics", displayMode: .inline)
            .task {
                await viewModel.fetchStats()
            }
            .refreshable {
                await viewModel.fetchStats()
            }
        }
    }
}

struct EarningsChartView: View {
    let dailyEarnings: [Double]
    let brandBlue: Color
    
    var maxEarning: Double {
        max(dailyEarnings.max() ?? 1, 1) // Avoid division by zero
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(0..<7) { index in
                VStack {
                    Spacer()
                    
                    // Show amount on top if > 0
                    if dailyEarnings[index] > 0 {
                        Text(String(format: "€%.0f", dailyEarnings[index]))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(brandBlue.opacity(index == 6 ? 1.0 : 0.5))
                        .frame(height: dailyEarnings[index] > 0 ? max(8, CGFloat(dailyEarnings[index] / maxEarning) * 100) : 4)
                    
                    Text(currentDayName(for: index))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(height: 150)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    func currentDayName(for offset: Int) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -(6 - offset), to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct StatsSummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RecentRideRowFromAPI: View {
    let ride: Ride
    
    var body: some View {
        NavigationLink(destination: RideDetailView(ride: ride)) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ride.displayCampaignName)
                        .foregroundColor(.primary)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(ride.formattedDuration) • \(ride.formattedDistance)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(ride.formattedEarnings)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding()
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
