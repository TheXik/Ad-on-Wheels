import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel: InboxViewModel
    @State private var selectedMessage: Message?
    private let userRole: String

    init(userId: Int = 0, userRole: String = "DRIVER") {
        self.userRole = userRole
        _viewModel = StateObject(wrappedValue: InboxViewModel(userId: userId, userRole: userRole))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                ProgressView("Loading messages...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.messages.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "envelope.open")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No messages yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text(userRole == "COMPANY"
                         ? "Messages from drivers will appear here."
                         : "Messages from companies will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(viewModel.messages) { message in
                        Button(action: {
                            selectedMessage = message
                            Task { await viewModel.markAsRead(message) }
                        }) {
                            InboxRow(
                                title: message.subject,
                                preview: message.preview,
                                date: message.relativeDate,
                                isUnread: !message.isRead
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarTitle("Inbox")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task { await viewModel.loadInbox() }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            await viewModel.loadInbox()
        }
        .sheet(item: $selectedMessage) { message in
            MessageDetailView(message: message, viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct InboxRow: View {
    let title: String
    let preview: String
    let date: String
    let isUnread: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(isUnread ? Color.blue : Color.clear)
                .frame(width: 10, height: 10)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(isUnread ? .bold : .regular)
                    Spacer()
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text(preview)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Message Detail View

struct MessageDetailView: View {
    let message: Message
    @ObservedObject var viewModel: InboxViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showReply = false
    @State private var replyText = ""
    @State private var isSending = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.subject)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack {
                            Image(systemName: message.senderRole == "COMPANY" ? "building.2" : "person")
                                .foregroundColor(.blue)
                            Text("From: \(message.senderRole == "COMPANY" ? "Company" : "Driver")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Text(message.relativeDate)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Divider()

                    // Body
                    Text(message.body)
                        .font(.body)
                        .lineSpacing(6)

                    Spacer().frame(height: 20)

                    // Reply section
                    if showReply {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reply")
                                .font(.headline)

                            TextEditor(text: $replyText)
                                .frame(minHeight: 100)
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )

                            Button(action: {
                                Task {
                                    isSending = true
                                    let success = await viewModel.sendMessage(
                                        campaignId: message.campaignId,
                                        recipientId: message.senderId,
                                        subject: "Re: \(message.subject)",
                                        body: replyText
                                    )
                                    isSending = false
                                    if success {
                                        dismiss()
                                    }
                                }
                            }) {
                                HStack {
                                    if isSending {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text("Send Reply")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(replyText.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(12)
                            }
                            .disabled(replyText.isEmpty || isSending)
                        }
                    } else {
                        Button(action: { showReply = true }) {
                            HStack {
                                Image(systemName: "arrowshape.turn.up.left.fill")
                                Text("Reply")
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InboxView(userId: 1)
        }
    }
}
