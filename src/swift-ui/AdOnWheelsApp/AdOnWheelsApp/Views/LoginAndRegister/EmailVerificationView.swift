import SwiftUI

struct EmailVerificationView: View {
    @StateObject private var viewModel: EmailVerificationViewModel
    @Environment(\.dismiss) private var dismiss
    var onVerified: (() -> Void)?

    init(email: String, onVerified: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EmailVerificationViewModel(email: email))
        self.onVerified = onVerified
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(viewModel.isVerified ? Color.green.opacity(0.1) : Color.accentBlue.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: viewModel.isVerified ? "checkmark.seal.fill" : "envelope.badge")
                    .font(.system(size: 42))
                    .foregroundColor(viewModel.isVerified ? .green : .accentBlue)
            }

            // Title
            VStack(spacing: 8) {
                Text(viewModel.isVerified ? "Email Verified!" : "Verify Your Email")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(viewModel.isVerified
                     ? "Your email has been verified successfully."
                     : "We sent a 6-digit code to\n\(viewModel.email)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if viewModel.isVerified {
                // Success state
                Button(action: {
                    onVerified?()
                    dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(14)
                }
                .padding(.horizontal, 40)
            } else {
                // Code input
                VStack(spacing: 16) {
                    TextField("000000", text: $viewModel.code)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding(16)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(14)
                        .padding(.horizontal, 40)
                        .onChange(of: viewModel.code) { newValue in
                            // Limit to 6 digits
                            if newValue.count > 6 {
                                viewModel.code = String(newValue.prefix(6))
                            }
                        }

                    Button(action: {
                        Task { await viewModel.verifyCode() }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Verify")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(viewModel.canVerify ? Color.accentBlue : Color.gray)
                        .cornerRadius(14)
                    }
                    .padding(.horizontal, 40)
                    .disabled(!viewModel.canVerify || viewModel.isLoading)

                    Button(action: {
                        Task { await viewModel.sendCode() }
                    }) {
                        Text("Resend code")
                            .font(.caption)
                            .foregroundColor(.accentBlue)
                    }
                }

                if let error = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                }
            }

            Spacer()

            if !viewModel.isVerified {
                Button(action: {
                    dismiss()
                }) {
                    Text("Skip for now")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}
