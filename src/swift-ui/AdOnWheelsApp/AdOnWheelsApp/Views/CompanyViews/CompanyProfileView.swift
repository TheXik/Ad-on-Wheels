import SwiftUI

struct CompanyProfileView: View {
    @ObservedObject var authService: AuthenticationService
    @AppStorage("isDarkMode") private var isDarkMode = false

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Circle()
                        .fill(brandBlue.opacity(0.12))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                                .foregroundColor(brandBlue)
                        )

                    VStack(spacing: 4) {
                        Text("Company XYZ")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Premium Advertiser")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)

                VStack(spacing: 0) {
                    profileMenuItem(icon: "person.circle", label: "Edit Profile")
                    Divider().padding(.leading, 56)
                    profileMenuItem(icon: "lock.shield", label: "Security")
                    Divider().padding(.leading, 56)
                    profileMenuItem(icon: "gearshape", label: "Settings")
                    Divider().padding(.leading, 56)
                    profileMenuItem(icon: "questionmark.circle", label: "Help & Support")
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)

                VStack(spacing: 0) {
                    profileMenuItem(icon: "doc.text", label: "Terms of Service")
                    Divider().padding(.leading, 56)
                    profileMenuItem(icon: "hand.raised", label: "Privacy Policy")
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)

                Button(action: {
                    authService.logout()
                }) {
                    HStack(spacing: 14) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.body)
                            .foregroundColor(.red)
                            .frame(width: 28)
                        Text("Log Out")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    func profileMenuItem(icon: String, label: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(brandBlue)
                .frame(width: 28)
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
