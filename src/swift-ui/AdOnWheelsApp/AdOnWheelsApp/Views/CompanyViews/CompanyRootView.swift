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
                    NavigationView {
                        CompanyCampaignsView(authService: authService)
                            .navigationBarHidden(true)
                    }
                case 1:
                    NavigationView {
                        CompanyApplicationsView(authService: authService)
                            .navigationBarHidden(true)
                    }
                case 2:
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
        HStack {
            tabBarButton(icon: "megaphone.fill", label: "Campaigns", index: 0)
            tabBarButton(icon: "person.2.fill", label: "Applications", index: 1)
            tabBarButton(icon: "person.fill", label: "Profile", index: 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(
            Color(UIColor.systemBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -4)
        )
    }

    func tabBarButton(icon: String, label: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(selectedTab == index ? brandBlue : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}
