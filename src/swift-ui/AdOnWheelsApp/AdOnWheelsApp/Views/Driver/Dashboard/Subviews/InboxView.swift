import SwiftUI

// Thread-style chat shared between driver and company surfaces.
struct InboxView: View {
    @StateObject private var viewModel: InboxViewModel
    private let userRole: String

    init(userId: Int = 0, userRole: String = "DRIVER") {
        self.userRole = userRole
        _viewModel = StateObject(wrappedValue: InboxViewModel(userId: userId, userRole: userRole))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.threads.isEmpty {
                ProgressView("Loading messages...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.threads.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.threads) { thread in
                        NavigationLink(destination: ConversationView(thread: thread, viewModel: viewModel)) {
                            ThreadRow(thread: thread)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarTitle("Messages")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task { await viewModel.loadThreads() }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            // 15s poll bound to view lifetime; .task cancels on disappear.
            await viewModel.loadThreads()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(15))
                guard !Task.isCancelled else { break }
                await viewModel.loadThreads()
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No conversations yet")
                .font(.headline)
                .foregroundColor(.gray)
            Text(userRole == "COMPANY"
                 ? "Start a thread from an accepted application, or wait for a driver to message you."
                 : "Once a company messages you, the conversation will show up here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct ThreadRow: View {
    let thread: MessageThread

    private var subtitleLine: String {
        if thread.subject.isEmpty { return thread.campaignName }
        return "\(thread.campaignName) · \(thread.subject)"
    }

    private var snippetLine: String {
        let m = thread.latest
        let mine = m.recipientId == thread.otherId && m.recipientRole == thread.otherRole
        return (mine ? "You: " : "") + m.preview
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(thread.unreadCount > 0 ? Color.blue : Color.clear)
                .frame(width: 10, height: 10)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                headerRow
                Text(subtitleLine)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(snippetLine)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private var headerRow: some View {
        HStack {
            Text(thread.otherName)
                .font(.headline)
                .fontWeight(thread.unreadCount > 0 ? .bold : .semibold)
            if thread.unreadCount > 0 {
                Text("\(thread.unreadCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            Spacer()
            Text(thread.latest.relativeDate)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// Bidirectional chat view. The bubble alignment is decided by senderId vs.
// the user's id — mine on the right (blue), theirs on the left (grey).
struct ConversationView: View {
    let thread: MessageThread
    @ObservedObject var viewModel: InboxViewModel
    @State private var replyText: String = ""
    @State private var isSending: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    if viewModel.isLoadingConversation && viewModel.conversation.isEmpty {
                        ProgressView()
                            .padding(.top, 40)
                    } else if viewModel.conversation.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 36))
                                .foregroundColor(.gray)
                            Text("No messages yet. Send the first one below.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.conversation) { m in
                                bubble(for: m)
                                    .id(m.id)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                    }
                }
                .onChange(of: viewModel.conversation.count) { _, _ in
                    if let last = viewModel.conversation.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Message…", text: $replyText, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)

                Button(action: send) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(canSend ? Color.blue : Color.gray)
                        .clipShape(Circle())
                }
                .disabled(!canSend || isSending)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .navigationTitle(thread.otherName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(thread.otherName)
                        .font(.headline)
                    Text(thread.campaignName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .task {
            // activeThread set here, not in loadConversation, so the race
            // window between disappear and an in-flight poll is empty.
            viewModel.activeThread = thread
            await viewModel.loadConversation(thread)
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(15))
                guard !Task.isCancelled else { break }
                await viewModel.loadConversation(thread, markRead: true)
            }
        }
        .onDisappear {
            viewModel.clearActiveThread()
        }
    }

    private var canSend: Bool {
        !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSending
    }

    @ViewBuilder
    private func bubble(for m: Message) -> some View {
        let mine = viewModel.isMine(m)
        HStack {
            if mine { Spacer(minLength: 40) }
            VStack(alignment: mine ? .trailing : .leading, spacing: 2) {
                Text(m.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(mine ? Color.blue : Color(.systemGray5))
                    .foregroundColor(mine ? .white : .primary)
                    .clipShape(
                        UnevenRoundedRectangle(
                            cornerRadii: mine
                                ? .init(topLeading: 16, bottomLeading: 16, bottomTrailing: 4, topTrailing: 16)
                                : .init(topLeading: 16, bottomLeading: 4, bottomTrailing: 16, topTrailing: 16)
                        )
                    )
                Text(m.formattedDateTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
            }
            if !mine { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: mine ? .trailing : .leading)
    }

    private func send() {
        let body = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else { return }
        let baseSubject = thread.subject.isEmpty ? "Conversation" : thread.subject
        let subject = baseSubject.hasPrefix("Re:") ? baseSubject : "Re: \(baseSubject)"
        isSending = true
        Task {
            let ok = await viewModel.sendMessage(
                campaignId: thread.campaignId,
                recipientId: thread.otherId,
                recipientRole: thread.otherRole,
                subject: subject,
                body: body
            )
            if ok {
                replyText = ""
                await viewModel.loadConversation(thread, markRead: false)
                await viewModel.loadThreads()
            }
            isSending = false
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
