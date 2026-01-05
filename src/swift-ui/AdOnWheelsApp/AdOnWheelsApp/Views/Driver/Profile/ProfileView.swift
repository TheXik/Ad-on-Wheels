import SwiftUI

struct ProfileView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel = DashboardViewModel() // Reuse for driver name
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white).shadow(radius: 5))
                        
                        VStack(spacing: 5) {
                            Text(viewModel.driverName)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Driver since Jan 2024")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 30)
                    
                    // Stats Summary
                    HStack(spacing: 20) {
                        ProfileStatBox(title: "Total Rides", value: "124")
                        ProfileStatBox(title: "Rating", value: String(format: "%.1f", viewModel.driverRating))
                        ProfileStatBox(title: "Earnings", value: "€3k+")
                    }
                    .padding(.horizontal)
                    
                    // Settings List
                    VStack(spacing: 0) {
                        NavigationLink(destination: VehicleView()) {
                            ProfileMenuItem(icon: "car.fill", title: "My Vehicle")
                        }
                        Divider()
                        
                        NavigationLink(destination: WalletView()) {
                            ProfileMenuItem(icon: "creditcard.fill", title: "Payment Details")
                        }
                        Divider()
                        
                        NavigationLink(destination: SettingsView()) {
                            ProfileMenuItem(icon: "gearshape.fill", title: "Settings")
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding()
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    // Logout
                    Button(action: {
                        authService.logout()
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

struct ProfileStatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(.blue)
            Text(title)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Assuming AuthenticationService has a default init or mock
        ProfileView(authService: AuthenticationService())
    }
}
