import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: viewModel.resetComplete ? "checkmark.circle.fill" : "lock.rotation")
                            .font(.system(size: 56))
                            .foregroundColor(viewModel.resetComplete ? .green : .accentBlue)

                        Text(headerTitle)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(headerSubtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 30)

                    if viewModel.resetComplete {
                        successView
                    } else if viewModel.step == .enterEmail {
                        emailStepView
                    } else {
                        codeStepView
                    }

                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.08))
                        .cornerRadius(10)
                    }
                }
                .padding(24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    var headerTitle: String {
        if viewModel.resetComplete { return "Password Reset!" }
        if viewModel.step == .enterEmail { return "Forgot Password?" }
        return "Enter Reset Code"
    }

    var headerSubtitle: String {
        if viewModel.resetComplete { return "Your password has been updated.\nYou can now log in with your new password." }
        if viewModel.step == .enterEmail { return "Enter your email and we'll send you\na code to reset your password." }
        return "Enter the 6-digit code sent to\n\(viewModel.email)"
    }

    var emailStepView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("your@email.com", text: $viewModel.email)
                    .textFieldStyle(.plain)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(14)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
            }

            Button(action: {
                Task { await viewModel.requestResetCode() }
            }) {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Send Reset Code")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding(.vertical, 14)
                .foregroundColor(.white)
                .background(viewModel.canRequestCode ? Color.accentBlue : Color.gray)
                .cornerRadius(14)
            }
            .disabled(!viewModel.canRequestCode || viewModel.isLoading)
        }
    }

    var codeStepView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Reset Code")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("6-digit code", text: $viewModel.resetCode)
                    .textFieldStyle(.plain)
                    .keyboardType(.numberPad)
                    .padding(14)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("New Password")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("Min 6 characters", text: $viewModel.newPassword)
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("Re-enter password", text: $viewModel.confirmPassword)
                    .textFieldStyle(.plain)
                    .padding(14)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)

                if viewModel.passwordMismatch {
                    Text("Passwords don't match")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }

            Button(action: {
                Task { await viewModel.resetPassword() }
            }) {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Reset Password")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding(.vertical, 14)
                .foregroundColor(.white)
                .background(viewModel.canResetPassword ? Color.accentBlue : Color.gray)
                .cornerRadius(14)
            }
            .disabled(!viewModel.canResetPassword || viewModel.isLoading)

            Button(action: {
                Task { await viewModel.requestResetCode() }
            }) {
                Text("Resend code")
                    .font(.caption)
                    .foregroundColor(.accentBlue)
            }
        }
    }

    var successView: some View {
        Button(action: { dismiss() }) {
            HStack {
                Spacer()
                Text("Back to Login")
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(14)
        }
    }
}
