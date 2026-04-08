import SwiftUI

@MainActor
class InboxViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var unreadCount: Int = 0

    private let api: APIClientProtocol
    private let userId: Int
    private let userRole: String
    private var pollTimer: Timer?

    init(userId: Int, userRole: String = "DRIVER", api: APIClientProtocol = APIClient.shared) {
        self.userId = userId
        self.userRole = userRole
        self.api = api
    }

    func loadInbox() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let endpoint = Endpoint(path: "api/messages/inbox/\(userId)")
            let fetched: [Message] = try await api.send(endpoint)
            self.messages = fetched
            self.unreadCount = fetched.filter { !$0.isRead }.count
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func startPolling(interval: TimeInterval = 15) {
        stopPolling()
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.loadInbox()
            }
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    func markAsRead(_ message: Message) async {
        guard !message.isRead else { return }
        do {
            let endpoint = Endpoint(
                path: "api/messages/\(message.id)/read",
                method: .patch
            )
            try await api.send(endpoint)
            await loadInbox()
        } catch {
            // Non-critical
        }
    }

    func sendMessage(campaignId: Int, recipientId: Int, recipientRole: String,
                     subject: String, body: String) async -> Bool {
        do {
            let request = SendMessageRequest(
                campaignId: campaignId,
                senderId: userId,
                senderRole: userRole,
                recipientId: recipientId,
                recipientRole: recipientRole,
                subject: subject,
                body: body
            )
            let bodyData = try JSONEncoder().encode(request)
            let endpoint = Endpoint(path: "api/messages", method: .post, body: bodyData)
            let _: Message = try await api.send(endpoint)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func loadConversation(campaignId: Int, otherUserId: Int) async -> [Message] {
        do {
            let endpoint = Endpoint(
                path: "api/messages/conversation",
                queryItems: [
                    URLQueryItem(name: "campaignId", value: String(campaignId)),
                    URLQueryItem(name: "userId1", value: String(userId)),
                    URLQueryItem(name: "userId2", value: String(otherUserId))
                ]
            )
            let conversation: [Message] = try await api.send(endpoint)
            return conversation
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
}
