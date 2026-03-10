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
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 36))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await viewModel.fetchApplications() }
                    }
                    .font(.subheadline)
                    .foregroundColor(brandBlue)
                }
                .padding()
                Spacer()
            } else if viewModel.applications.isEmpty {
                Spacer()
                VStack(spacing: 14) {
                    Image(systemName: "person.2")
                        .font(.system(size: 44))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No applications yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("When drivers apply to your campaigns,\nthey'll appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
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
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .padding(.bottom, 70)
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
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.fill")
                        .foregroundColor(statusColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(application.driver.name)
                        .font(.headline)
                    Text(application.campaignName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(application.status.capitalized)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(8)
            }

            HStack(spacing: 16) {
                Label(application.driver.vehicleDisplayName, systemImage: "car.fill")
                if let rating = application.driver.rating {
                    Label(String(format: "%.1f", rating), systemImage: "star.fill")
                        .foregroundColor(.orange)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)

            if application.status.uppercased() == "APPLIED" {
                HStack(spacing: 10) {
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
                        .background(Color.red.opacity(0.08))
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
