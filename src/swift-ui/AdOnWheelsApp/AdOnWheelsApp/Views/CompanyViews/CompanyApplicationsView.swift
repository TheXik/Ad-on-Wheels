import SwiftUI

struct CompanyApplicationsView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel: CompanyApplicationsViewModel

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(authService: AuthenticationService) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: CompanyApplicationsViewModel(companyId: authService.userId ?? 0))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Applications")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading applications...")
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await viewModel.fetchApplications() }
                    }
                }
                .padding()
                Spacer()
            } else if viewModel.applications.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "person.2")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No applications yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("When drivers apply to your campaigns,\nthey'll appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.applications) { app in
                            ApplicationCardView(
                                application: app,
                                isProcessing: viewModel.actionInProgress == app.id,
                                onAccept: {
                                    Task { await viewModel.acceptApplication(app.id) }
                                },
                                onDecline: {
                                    Task { await viewModel.declineApplication(app.id) }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .task {
            await viewModel.fetchApplications()
        }
    }
}

struct ApplicationCardView: View {
    let application: ApplicationWithDriver
    let isProcessing: Bool
    let onAccept: () -> Void
    let onDecline: () -> Void

    var statusColor: Color {
        switch application.status.uppercased() {
        case "ACCEPTED": return .green
        case "DECLINED": return .red
        default: return .orange
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(application.driver.name)
                        .font(.headline)
                    Text(application.campaignName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(application.status.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.12))
                    .cornerRadius(8)
            }

            HStack(spacing: 16) {
                Label(application.driver.vehicleDisplayName, systemImage: "car.fill")
                if let rating = application.driver.rating {
                    Label(String(format: "%.1f", rating), systemImage: "star.fill")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)

            if application.status.uppercased() == "APPLIED" {
                HStack(spacing: 12) {
                    Button(action: onDecline) {
                        HStack {
                            Spacer()
                            if isProcessing {
                                ProgressView()
                                    .tint(.red)
                            } else {
                                Text("Decline")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                    .disabled(isProcessing)

                    Button(action: onAccept) {
                        HStack {
                            Spacer()
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Accept")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}
