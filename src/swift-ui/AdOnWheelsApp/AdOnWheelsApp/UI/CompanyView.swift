import SwiftUI

struct CompanyView: View {
    @StateObject var viewModel: CompanyViewModel

    var body: some View {
        VStack {
            Button("Logout") {
                viewModel.selectedCompanyId = nil
            }
            .buttonStyle(.bordered)
            .padding(.bottom)

            // Pending Applications
            if !viewModel.appliedApplicationsWithDriver.isEmpty {
                Text("Pending Applications")
                    .font(.headline)
                List(viewModel.appliedApplicationsWithDriver) { app in
                    VStack(alignment: .leading) {
                        Text("Campaign: \(app.campaignName)")
                        Text("Driver: \(app.driver.name) (\(app.driver.email))")
                        HStack {
                            Button("Accept") {
                                Task {
                                    await viewModel.acceptApplication(applicationId: app.id)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            Button("Decline") {
                                Task {
                                    await viewModel.declineApplication(applicationId: app.id)
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Accepted Drivers
            if !viewModel.acceptedApplicationsWithDriver.isEmpty {
                Text("Accepted Drivers")
                    .font(.headline)
                List(viewModel.acceptedApplicationsWithDriver) { app in
                    VStack(alignment: .leading) {
                        Text("Campaign: \(app.campaignName)")
                        Text("Driver: \(app.driver.name) (\(app.driver.email))")
                        Text("Status: Accepted")
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchCompanyApplicationsWithDrivers()
            }
        }
    }
}

