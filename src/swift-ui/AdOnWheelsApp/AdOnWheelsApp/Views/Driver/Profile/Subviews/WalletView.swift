import SwiftUI

struct WalletView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Balance Card
                VStack(spacing: 10) {
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Text("€1,240.50")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Button(action: {}) {
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
                
                // Transaction History
                VStack(alignment: .leading, spacing: 15) {
                    Text("History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        TransactionRow(title: "Monthly Payout - April", date: "Apr 15", amount: "+€420.00")
                        Divider()
                        TransactionRow(title: "Monthly Payout - March", date: "Mar 15", amount: "+€410.00")
                        Divider()
                        TransactionRow(title: "Bonus", date: "Mar 01", amount: "+€50.00")
                    }
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Wallet")
    }
}

struct TransactionRow: View {
    let title: String
    let date: String
    let amount: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(amount)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding()
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletView()
        }
    }
}
