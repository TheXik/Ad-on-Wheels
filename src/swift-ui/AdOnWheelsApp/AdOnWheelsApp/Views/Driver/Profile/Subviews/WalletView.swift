import SwiftUI

struct WalletView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showCashOutAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Balance Card
                VStack(spacing: 10) {
                    Text("Total Earnings")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Text(viewModel.formattedBalance)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Button(action: { showCashOutAlert = true }) {
                        Text("Cash Out")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.blue)
                .cornerRadius(20)
                .padding()
                .shadow(radius: 5)
                
                // Summary Stats from Backend
                VStack(alignment: .leading, spacing: 15) {
                    Text("Earnings Summary")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        SummaryCard(
                            title: "This Week",
                            value: viewModel.statistics?.formattedWeeklyEarnings ?? "€0.00",
                            color: .green
                        )
                        SummaryCard(
                            title: "This Month",
                            value: viewModel.statistics?.formattedMonthlyEarnings ?? "€0.00",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Additional Stats
                VStack(alignment: .leading, spacing: 15) {
                    Text("Performance Stats")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        StatRow(label: "Total Rides", value: "\(viewModel.totalRides)")
                        Divider()
                        StatRow(label: "Total Distance", value: viewModel.statistics?.formattedTotalDistance ?? "0 km")
                        Divider()
                        StatRow(label: "Average Speed", value: viewModel.statistics?.formattedAverageSpeed ?? "0 km/h")
                    }
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 50)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Wallet")
        .alert(isPresented: $showCashOutAlert) {
            Alert(
                title: Text("Coming Soon"),
                message: Text("Cash out functionality will be available in a future update."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding()
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletView(viewModel: ProfileViewModel(authService: AuthenticationService()))
        }
    }
}
