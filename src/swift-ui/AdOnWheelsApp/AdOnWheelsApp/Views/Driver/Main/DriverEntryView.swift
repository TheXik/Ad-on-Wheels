import SwiftUI

struct DriverEntryView: View {
    @ObservedObject var authService: AuthenticationService
    @State private var driver: Driver?
    @State private var isLoading = true
    @State private var onboardingDone = false
    @State private var loadFailed = false

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading your profile...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if loadFailed {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Couldn't load your profile")
                        .font(.headline)
                    Button {
                        Task { await loadDriver() }
                    } label: {
                        Text("Try Again")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(brandBlue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    Button {
                        authService.logout()
                    } label: {
                        Text("Sign Out")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
            } else if let driver = driver, driver.needsOnboarding && !onboardingDone {
                DriverOnboardingView(
                    driverName: driver.name,
                    authService: authService,
                    onComplete: { onboardingDone = true }
                )
            } else {
                DriverRootView(authService: authService)
            }
        }
        .task {
            await loadDriver()
        }
    }

    private func loadDriver() async {
        isLoading = true
        loadFailed = false

        guard let driverId = authService.userId else {
            isLoading = false
            return
        }

        do {
            let endpoint = Endpoint(path: "api/drivers/\(driverId)/home")
            let response: DriverHomePageResponse = try await APIClient.shared.send(endpoint)
            self.driver = response.driver
        } catch {
            loadFailed = true
        }

        isLoading = false
    }
}
