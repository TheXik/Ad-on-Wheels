import SwiftUI

struct StatsView: View {
    @State private var selectedPeriod = 0 // 0: Weekly, 1: Monthly
    
    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    
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
                    
                    // Main Summary Cards
                    HStack(spacing: 15) {
                        StatsSummaryCard(title: "Total Earnings", value: "€420.50", icon: "eurosign.circle.fill", color: .green)
                        StatsSummaryCard(title: "Total Distance", value: "854 km", icon: "speedometer", color: brandBlue)
                    }
                    .padding(.horizontal)
                    
                    // Chart Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Earnings History")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Mock Bar Chart
                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(0..<7) { index in
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(brandBlue.opacity(index == 6 ? 1.0 : 0.3)) // Highlight today
                                        .frame(height: CGFloat.random(in: 40...120))
                                    Text(days[index])
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
                        .padding(.horizontal)
                    }
                    
                    // Recent Rides List
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(0..<5) { _ in
                                RecentRideRow()
                                Divider()
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitle("Statistics", displayMode: .inline)
        }
    }
    
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
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

struct RecentRideRow: View {
    var body: some View {
        NavigationLink(destination: RideDetailView()) {
            HStack {
                Image(systemName: "car.fill")
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ride to Center")
                        .foregroundColor(.primary) // Reset for link color
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Today, 14:30 • 12.5 km")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("+€4.20")
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
