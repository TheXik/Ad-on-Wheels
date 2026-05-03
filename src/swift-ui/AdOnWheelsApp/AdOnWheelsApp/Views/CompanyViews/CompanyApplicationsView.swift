import SwiftUI

enum DriverSortOption: String, CaseIterable {
    case newest = "Newest"
    case nameAZ = "Name A–Z"
}

struct CompanyApplicationsView: View {
    @ObservedObject var dashboard: CompanyDashboardViewModel
    @State private var selectedFilter = 0
    @State private var searchText = ""
    @State private var sortOption: DriverSortOption = .newest
    @State private var showFilters = false

    var activeFilterCount: Int {
        var count = 0
        if !searchText.isEmpty { count += 1 }
        if sortOption != .newest { count += 1 }
        return count
    }

    var filteredApplications: [ApplicationWithDriver] {
        var result: [ApplicationWithDriver]
        switch selectedFilter {
        case 0: result = dashboard.applications
        case 1: result = dashboard.applications.filter { $0.status.uppercased() == "APPLIED" }
        case 2: result = dashboard.applications.filter { $0.status.uppercased() == "ACCEPTED" }
        case 3: result = dashboard.applications.filter { $0.status.uppercased() == "DECLINED" }
        default: result = dashboard.applications
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.driver.name.lowercased().contains(query) ||
                $0.driver.vehicleDisplayName.lowercased().contains(query) ||
                $0.campaignName.lowercased().contains(query)
            }
        }

        switch sortOption {
        case .newest:
            break
        case .nameAZ:
            result.sort { $0.driver.name.lowercased() < $1.driver.name.lowercased() }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Applications")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Spacer()
                    if !dashboard.applications.isEmpty {
                        Button(action: { withAnimation { showFilters.toggle() } }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(showFilters ? .white : .accentBlue)
                                    .frame(width: 34, height: 34)
                                    .background(showFilters ? Color.accentBlue : Color.accentBlue.opacity(0.1))
                                    .clipShape(Circle())
                                if activeFilterCount > 0 {
                                    Text("\(activeFilterCount)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Color.orange)
                                        .clipShape(Circle())
                                        .offset(x: 4, y: -4)
                                }
                            }
                        }
                    }
                }

                if !dashboard.applications.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search drivers, vehicles, campaigns...", text: $searchText)
                            .font(.subheadline)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }

                if showFilters {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Sort by")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Menu {
                                ForEach(DriverSortOption.allCases, id: \.self) { option in
                                    Button(action: { sortOption = option }) {
                                        if sortOption == option {
                                            Label(option.rawValue, systemImage: "checkmark")
                                        } else {
                                            Text(option.rawValue)
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(sortOption.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption2)
                                }
                                .foregroundColor(.primary)
                            }
                        }

                        if activeFilterCount > 0 {
                            Button(action: {
                                searchText = ""
                                sortOption = .newest
                            }) {
                                Text("Clear all filters")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.cardBackground)
                    .cornerRadius(14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
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
                                companyId: dashboard.companyId,
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
    let companyId: Int
    let onAccept: () -> Void
    let onDecline: () -> Void
    @State private var showComposeMessage = false

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
            }
            .font(.caption)
            .foregroundColor(.secondary)

            if let url = application.driver.resolvedVehicleImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        ZStack {
                            Color(.systemGray6)
                            Image(systemName: "car.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    default:
                        ZStack {
                            Color(.systemGray6)
                            ProgressView()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipped()
                .cornerRadius(12)
            }

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

            if application.status.uppercased() == "ACCEPTED" {
                Button(action: { showComposeMessage = true }) {
                    HStack {
                        Spacer()
                        Image(systemName: "envelope.fill")
                        Text("Message Driver")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.vertical, 11)
                    .foregroundColor(.accentBlue)
                    .background(Color.accentBlue.opacity(0.08))
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .sheet(isPresented: $showComposeMessage) {
            ComposeMessageView(
                senderId: companyId,
                senderRole: "COMPANY",
                recipientId: application.driver.id,
                recipientRole: "DRIVER",
                recipientName: application.driver.name,
                campaignId: application.campaignId,
                campaignName: application.campaignName
            )
        }
    }
}
