import SwiftUI

struct DriverRootView: View {
    @ObservedObject var authService: AuthenticationService
    
    // Custom Blue Color from design
    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    init(authService: AuthenticationService) {
        self.authService = authService
    }

    var body: some View {
        TabView {
            // Home Tab
            NavigationView {
                DashboardView(authService: authService)
                    .navigationBarHidden(true) // Hide nav bar to use custom header
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            // Browse Tab
            NavigationView {
                BrowseView()
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "car.fill")
                Text("Browse")
            }
            
            // Stats Tab
            StatsView(authService: authService)
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Stats")
            }
            
            // Profile Tab
            ProfileView(authService: authService)
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
        .accentColor(brandBlue)
    }
}

