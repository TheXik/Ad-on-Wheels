import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @StateObject private var dashboardVM = DashboardViewModel(authService: AuthenticationService())
    @State private var goalText = ""
    @State private var showClearDataAlert = false
    
    private let historyService = RideHistoryService.shared
    
    var body: some View {
        List {
            Section(header: Text("Appearance")) {
                Toggle(isOn: $isDarkMode) {
                    HStack {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .purple : .orange)
                        Text("Dark Mode")
                    }
                }
            }
            
            Section(header: Text("Goals")) {
                HStack {
                    Text("Monthly Goal")
                    Spacer()
                    TextField("200", text: $goalText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("km")
                        .foregroundColor(.gray)
                }
                .onAppear {
                    goalText = String(format: "%.0f", dashboardVM.monthlyGoalTotal)
                }
                .onChange(of: goalText) { newValue in
                    if let goal = Double(newValue), goal > 0 {
                        dashboardVM.setMonthlyGoal(goal)
                    }
                }
            }
            
            Section(header: Text("Data")) {
                HStack {
                    Text("Total Rides")
                    Spacer()
                    Text("\(historyService.totalRides)")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Total Distance")
                    Spacer()
                    Text(historyService.formattedTotalDistance)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Total Earnings")
                    Spacer()
                    Text(historyService.formattedTotalEarnings)
                        .foregroundColor(.gray)
                }
                
                Button(action: { showClearDataAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Clear All Ride Data")
                            .foregroundColor(.red)
                    }
                }
            }
            
            Section(header: Text("App Info")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Settings")
        .alert(isPresented: $showClearDataAlert) {
            Alert(
                title: Text("Clear All Data?"),
                message: Text("This will permanently delete all your ride history and statistics. This action cannot be undone."),
                primaryButton: .destructive(Text("Clear")) {
                    historyService.clearAllRides()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
