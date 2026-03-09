import SwiftUI

struct CompanyProfileView: View {
    @ObservedObject var authService: AuthenticationService
    @AppStorage("isDarkMode") private var isDarkMode = false

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Circle()
                            .fill(brandBlue.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "building.2.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(brandBlue)
                            )

                        VStack(spacing: 5) {
                            Text("Company")
                                .font(.title)
                                .fontWeight(.bold)
                            if let id = authService.userId {
                                Text("ID: \(id)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.top, 30)

                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                .frame(width: 30)
                                .foregroundColor(isDarkMode ? .purple : .orange)
                            Text("Dark Mode")
                                .foregroundColor(.primary)
                            Spacer()
                            Toggle("", isOn: $isDarkMode)
                                .labelsHidden()
                        }
                        .padding()
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    Button(action: {
                        authService.logout()
                    }) {
                        Text("Log Out")
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
        }
    }
}
