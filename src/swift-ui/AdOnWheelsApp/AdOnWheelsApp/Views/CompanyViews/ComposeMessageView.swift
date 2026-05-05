import SwiftUI

struct ComposeMessageView: View {
    let senderId: Int
    let senderRole: String
    let recipientId: Int
    let recipientRole: String
    let recipientName: String
    let campaignId: Int
    let campaignName: String

    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var messageBody = ""
    @State private var isSending = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private let api: APIClientProtocol = APIClient.shared

    var canSend: Bool {
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !messageBody.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var bodyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.accentBlue.opacity(0.1))
                            .frame(width: 44, height: 44)
                        Text(String(recipientName.prefix(1)).uppercased())
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.accentBlue)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("To: \(recipientName)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Re: \(campaignName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground)
                .cornerRadius(14)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Subject")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Enter subject", text: $subject)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Message")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $messageBody)
                        .frame(minHeight: 150)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                }

                if let error = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Button(action: sendMessage) {
                    HStack {
                        Spacer()
                        if isSending {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Send Message")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background(canSend ? Color.accentBlue : Color.gray)
                    .cornerRadius(14)
                }
                .disabled(!canSend || isSending)
            }
            .padding(20)
        }
    }

    var successContent: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            Text("Message Sent!")
                .font(.title2)
                .fontWeight(.bold)
            Text("Your message to \(recipientName) has been delivered.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Done") { dismiss() }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.accentBlue)
                .padding(.top, 8)
            Spacer()
        }
        .padding(20)
    }

    var body: some View {
        NavigationStack {
            Group {
                if showSuccess {
                    successContent
                } else {
                    bodyContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.pageBackground)
            .dismissKeyboardOnTap()
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func sendMessage() {
        isSending = true
        errorMessage = nil
        Task {
            do {
                let request = SendMessageRequest(
                    campaignId: campaignId,
                    senderId: senderId,
                    senderRole: senderRole,
                    recipientId: recipientId,
                    recipientRole: recipientRole,
                    subject: subject,
                    body: messageBody
                )
                let bodyData = try JSONEncoder().encode(request)
                let endpoint = Endpoint(path: "api/messages", method: .post, body: bodyData)
                let _: Message = try await api.send(endpoint)
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isSending = false
        }
    }
}
