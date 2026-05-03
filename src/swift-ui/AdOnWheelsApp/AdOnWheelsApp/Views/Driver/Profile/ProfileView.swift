import SwiftUI

struct ProfileView: View {
    @ObservedObject var authService: AuthenticationService
    @StateObject private var viewModel: ProfileViewModel

    init(authService: AuthenticationService) {
        self.authService = authService
        _viewModel = StateObject(wrappedValue: ProfileViewModel(authService: authService))
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading profile...")
                            .padding(.top, 50)
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        VStack(spacing: 15) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(red: 0.0, green: 0.478, blue: 1.0))
                            
                            VStack(spacing: 5) {
                                Text(viewModel.driverName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("Driver since \(viewModel.memberSince)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 30)
                        
                        HStack(spacing: 20) {
                            ProfileStatBox(title: "Total Rides", value: "\(viewModel.totalRides)")
                            ProfileStatBox(title: "Earnings", value: viewModel.formattedTotalEarnings)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            NavigationLink(destination: VehicleView(viewModel: viewModel)) {
                                ProfileMenuItem(icon: "car.fill", title: "My Vehicle")
                            }
                            Divider()
                            
                            NavigationLink(destination: WalletView(viewModel: viewModel)) {
                                ProfileMenuItem(icon: "creditcard.fill", title: "Payment Details")
                            }
                            Divider()
                            
                            NavigationLink(destination: SettingsView(authService: authService)) {
                                ProfileMenuItem(icon: "gearshape.fill", title: "Settings")
                            }
                        }
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding()
                    }
                    
                    Button(action: {
                        authService.logout()
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .task {
                await viewModel.fetchProfile()
            }
            .refreshable {
                await viewModel.fetchProfile()
            }
        }
        .navigationViewStyle(.stack)
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
                .foregroundColor(Color(red: 0.0, green: 0.478, blue: 1.0))
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(Color(red: 0.0, green: 0.478, blue: 1.0))
            Text(title)
                .foregroundColor(.primary)
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
