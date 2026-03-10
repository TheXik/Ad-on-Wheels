import SwiftUI

struct CompanyProfileView: View {
    @ObservedObject var dashboard: CompanyDashboardViewModel
    @ObservedObject var authService: AuthenticationService

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                profileHeader
                mainMenuSection
                legalSection
                logoutButton
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 80)
        }
        .background(Color.pageBackground)
    }

    var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentBlue.opacity(0.2), Color.accentBlue.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                Image(systemName: "building.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.accentBlue)
            }

            VStack(spacing: 6) {
                Text(dashboard.companyName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                if let email = dashboard.company?.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 24) {
                profileStat(value: "\(dashboard.campaigns.count)", label: "Campaigns")
                profileStat(value: "\(dashboard.acceptedDriverCount)", label: "Drivers")
                profileStat(value: String(format: "€%.0f", dashboard.totalBudget), label: "Budget")
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.cardBackground)
        .cornerRadius(20)
    }

    func profileStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    var mainMenuSection: some View {
        VStack(spacing: 0) {
            profileMenuItem(icon: "person.circle", label: "Edit Profile")
            Divider().padding(.leading, 56)
            profileMenuItem(icon: "lock.shield", label: "Security")
            Divider().padding(.leading, 56)
            profileMenuItem(icon: "gearshape", label: "Settings")
            Divider().padding(.leading, 56)
            profileMenuItem(icon: "questionmark.circle", label: "Help & Support")
        }
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    var legalSection: some View {
        VStack(spacing: 0) {
            profileMenuItem(icon: "doc.text", label: "Terms of Service")
            Divider().padding(.leading, 56)
            profileMenuItem(icon: "hand.raised", label: "Privacy Policy")
        }
        .background(Color.cardBackground)
        .cornerRadius(16)
    }

    var logoutButton: some View {
        Button(action: { authService.logout() }) {
            HStack(spacing: 14) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.body)
                    .foregroundColor(.red)
                    .frame(width: 28)
                Text("Log Out")
                    .foregroundColor(.red)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }

    func profileMenuItem(icon: String, label: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.accentBlue)
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
