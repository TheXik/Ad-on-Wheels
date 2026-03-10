import SwiftUI

struct CompanyRootView: View {
    @ObservedObject var authService: AuthenticationService
    @State private var selectedTab: Int = 0

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    CompanyHomeView(authService: authService)
                case 1:
                    NavigationView {
                        CompanyApplicationsView(authService: authService)
                            .navigationBarHidden(true)
                    }
                case 2:
                    NavigationView {
                        CompanyCampaignsView(authService: authService)
                            .navigationBarHidden(true)
                    }
                case 3:
                    CompanyStatsView(authService: authService)
                case 4:
                    CompanyProfileView(authService: authService)
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .edgesIgnoringSafeArea(.bottom)
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
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Color(UIColor.systemBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: -4)
        )
    }

    func tabBarButton(icon: String, label: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular))
            }
            .foregroundColor(selectedTab == index ? brandBlue : .gray.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
    }
}
