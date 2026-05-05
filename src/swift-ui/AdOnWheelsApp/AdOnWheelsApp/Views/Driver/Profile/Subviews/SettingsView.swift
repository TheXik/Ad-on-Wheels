import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showClearDataAlert = false
    @State private var isClearing = false
    @State private var clearError: String?

    @State private var totalRides: Int = 0
    @State private var totalDistance: Double = 0
    @State private var totalEarnings: Double = 0

    let authService: AuthenticationService
    private let api: APIClientProtocol = APIClient.shared

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

            Section(header: Text("Data")) {
                HStack {
                    Text("Total Rides")
                    Spacer()
                    Text("\(totalRides)")
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Total Distance")
                    Spacer()
                    Text(formattedDistance)
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Total Earnings")
                    Spacer()
                    Text(formattedEarnings)
                        .foregroundColor(.gray)
                }

                Button(action: { showClearDataAlert = true }) {
                    HStack {
                        if isClearing {
                            ProgressView()
                                .frame(width: 20, height: 20)
                        } else {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        Text("Clear All Ride Data")
                            .foregroundColor(.red)
                    }
                }
                .disabled(isClearing)
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
        .keyboardDoneButton()
        .navigationBarTitle("Settings")
        .task { await fetchStats() }
        .alert(isPresented: $showClearDataAlert) {
            Alert(
                title: Text("Clear All Data?"),
                message: Text("This will permanently delete all your ride history and statistics. This action cannot be undone."),
                primaryButton: .destructive(Text("Clear")) {
                    Task { await clearAllData() }
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Error", isPresented: .constant(clearError != nil)) {
            Button("OK") { clearError = nil }
        } message: {
            Text(clearError ?? "")
        }
    }

    private var formattedDistance: String {
        if totalDistance >= 1000 {
            return String(format: "%.1fk km", totalDistance / 1000)
        }
        return String(format: "%.1f km", totalDistance)
    }

    private var formattedEarnings: String {
        if totalEarnings >= 1000 {
            return String(format: "€%.1fk", totalEarnings / 1000)
        }
        return String(format: "€%.2f", totalEarnings)
    }

    private func fetchStats() async {
        guard let driverId = authService.userId else { return }
        do {
            let endpoint = Endpoint(path: "api/drivers/\(driverId)/statistics")
            let stats: RideStatistics = try await api.send(endpoint)
            totalRides = Int(stats.totalRides)
            totalDistance = stats.totalDistanceKm ?? 0
            totalEarnings = stats.totalEarnings ?? 0
        } catch {}
    }

    private func clearAllData() async {
        guard let driverId = authService.userId else { return }
        isClearing = true
        defer { isClearing = false }

        do {
            let endpoint = Endpoint(path: "api/drivers/\(driverId)/rides", method: .delete)
            try await api.send(endpoint)
            totalRides = 0
            totalDistance = 0
            totalEarnings = 0
            NotificationCenter.default.post(name: .rideCompleted, object: nil)
        } catch {
            clearError = "Failed to clear data. Please try again."
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(authService: AuthenticationService())
        }
    }
}
