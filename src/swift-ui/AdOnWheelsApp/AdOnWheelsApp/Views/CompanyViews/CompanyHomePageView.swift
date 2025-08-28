import SwiftUI

struct CompanyHomePageView: View {
    @StateObject private var viewModel = CompanyHomePageViewModel()
    @ObservedObject var authService: AuthenticationService

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading companies..")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Mistake in loading the data")
                            .font(.headline)
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                        Button("Try again") {
                            Task {
                                await viewModel.fetchCompanies()
                            }
                        }
                    }
                } else {
                    List(viewModel.company) { driver in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(driver.name).font(.headline)
                            Text(driver.email).font(.subheadline).foregroundColor(.secondary)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("All Companies")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        authService.logout()
                    }
                }
            }
            .onAppear {
                if viewModel.company.isEmpty {
                    Task {
                        await viewModel.fetchCompanies()
                    }
                }
            }
        }
    }
}

