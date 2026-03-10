import SwiftUI

struct CompanyRootView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var dashboard: CompanyDashboardViewModel
    @State private var selectedTab: Int = 0

    init(authService: AuthenticationService) {
        self.authService = authService
        _dashboard = StateObject(wrappedValue: CompanyDashboardViewModel(companyId: authService.userId ?? 0))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    CompanyHomeView(dashboard: dashboard)
                case 1:
                    CompanyApplicationsView(dashboard: dashboard)
                case 2:
                    NavigationView {
                        CompanyCampaignsView(dashboard: dashboard)
                            .navigationBarHidden(true)
                    }
                case 3:
                    CompanyStatsView(dashboard: dashboard)
                case 4:
                    CompanyProfileView(dashboard: dashboard, authService: authService)
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .edgesIgnoringSafeArea(.bottom)
        .task {
            await dashboard.loadAll()
        }
    }

    var customTabBar: some View {
        HStack(spacing: 0) {
            tabBarButton(icon: "house.fill", label: "Home", index: 0)
            tabBarButton(icon: "person.2.fill", label: "Drivers", index: 1)
            tabBarButton(icon: "megaphone.fill", label: "Campaigns", index: 2)
            tabBarButton(icon: "chart.bar.fill", label: "Stats", index: 3)
            tabBarButton(icon: "person.fill", label: "Profile", index: 4)
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: -8)
        )
    }

    func tabBarButton(icon: String, label: String, index: Int) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.15)) { selectedTab = index } }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: selectedTab == index ? .semibold : .regular))
                Text(label)
                    .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular))
            }
            .foregroundColor(selectedTab == index ? Color.accentBlue : .gray.opacity(0.5))
            .frame(maxWidth: .infinity)
        }
    }
}

extension Color {
    static let accentBlue = Color(red: 0.2, green: 0.4, blue: 1.0)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let pageBackground = Color(UIColor.systemGroupedBackground)
}
