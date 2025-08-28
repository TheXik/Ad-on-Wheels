import SwiftUI

struct HomePageView: View {
    @StateObject private var viewModel = HomePageViewModel()
    @ObservedObject var authService: AuthenticationService

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading drivers..")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Mistake in loading the data")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                        Button("Try again") {
                            Task {
                                await viewModel.fetchDrivers()
                            }
                        }
                    }
                } else {
                    List(viewModel.drivers) { driver in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(driver.name).font(.headline)
                            Text(driver.email).font(.subheadline).foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("All Drivers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        authService.logout()
                    }
                }
            }
            .onAppear {
                if viewModel.drivers.isEmpty {
                    Task {
                        await viewModel.fetchDrivers()
                    }
                }
            }
        }
    }
}

