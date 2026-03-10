import SwiftUI

struct CompanyApplicationsView: View {
    @ObservedObject var dashboard: CompanyDashboardViewModel
    @State private var selectedFilter = 0

    var filteredApplications: [ApplicationWithDriver] {
        switch selectedFilter {
        case 0: return dashboard.applications
        case 1: return dashboard.applications.filter { $0.status.uppercased() == "APPLIED" }
        case 2: return dashboard.applications.filter { $0.status.uppercased() == "ACCEPTED" }
        case 3: return dashboard.applications.filter { $0.status.uppercased() == "DECLINED" }
        default: return dashboard.applications
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Applications")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Spacer()
                    if !dashboard.applications.isEmpty {
                        Text("\(dashboard.applications.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }

                if !dashboard.applications.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterChip("All", tag: 0, count: dashboard.applications.count)
                            filterChip("Pending", tag: 1, count: dashboard.applications.filter { $0.status.uppercased() == "APPLIED" }.count)
                            filterChip("Accepted", tag: 2, count: dashboard.applications.filter { $0.status.uppercased() == "ACCEPTED" }.count)
                            filterChip("Declined", tag: 3, count: dashboard.applications.filter { $0.status.uppercased() == "DECLINED" }.count)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if dashboard.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = dashboard.errorMessage {
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
                        Task { await dashboard.fetchApplications() }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentBlue)
                }
                .padding()
                Spacer()
            } else if filteredApplications.isEmpty {
                Spacer()
                VStack(spacing: 14) {
                    Image(systemName: "person.2")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text(selectedFilter == 0 ? "No applications yet" : "No \(filterLabel.lowercased()) applications")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    if selectedFilter == 0 {
                        Text("When drivers apply to your campaigns,\nthey'll appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredApplications) { app in
                            ApplicationCard(
                                application: app,
                                isProcessing: dashboard.actionInProgress == app.id,
                                onAccept: {
                                    Task { await dashboard.acceptApplication(app.id) }
                                },
                                onDecline: {
                                    Task { await dashboard.declineApplication(app.id) }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .padding(.bottom, 80)
                }
            }
        }
        .background(Color.pageBackground)
    }

    var filterLabel: String {
        switch selectedFilter {
        case 1: return "Pending"
        case 2: return "Accepted"
        case 3: return "Declined"
        default: return "All"
        }
    }

    func filterChip(_ label: String, tag: Int, count: Int) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = tag } }) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(selectedFilter == tag ? .semibold : .regular)
                if count > 0 && tag != 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(selectedFilter == tag ? Color.white.opacity(0.3) : Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(selectedFilter == tag ? Color.accentBlue : Color.cardBackground)
            .foregroundColor(selectedFilter == tag ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct ApplicationCard: View {
    let application: ApplicationWithDriver
    let isProcessing: Bool
    let onAccept: () -> Void
    let onDecline: () -> Void

    private var actionInProgress: Int? { nil }

    var statusColor: Color {
        switch application.status.uppercased() {
        case "ACCEPTED": return .green
        case "DECLINED": return .red
        default: return .orange
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Text(String(application.driver.name.prefix(1)).uppercased())
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(application.driver.name)
                        .font(.headline)
                    Text(application.campaignName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(application.status.capitalized)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusColor.opacity(0.1))
                    .clipShape(Capsule())
            }

            HStack(spacing: 16) {
                if !application.driver.vehicleDisplayName.isEmpty {
                    Label(application.driver.vehicleDisplayName, systemImage: "car.fill")
                }
                if let rating = application.driver.rating, rating > 0 {
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
                        .padding(.vertical, 11)
                        .background(Color.red.opacity(0.08))
                        .foregroundColor(.red)
                        .cornerRadius(12)
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
                        .padding(.vertical, 11)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}
