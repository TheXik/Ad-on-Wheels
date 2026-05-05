import SwiftUI

// Thread key = (campaignId, otherRole, otherId). Same view backs driver + company.
struct MessageThread: Identifiable, Equatable {
    let id: String
    let campaignId: Int
    let campaignName: String
    let otherId: Int
    let otherRole: String
    var otherName: String
    let latest: Message
    let unreadCount: Int
    let subject: String

    static func == (lhs: MessageThread, rhs: MessageThread) -> Bool { lhs.id == rhs.id }
}

@MainActor
class InboxViewModel: ObservableObject {
    @Published var threads: [MessageThread] = []
    @Published var conversation: [Message] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var isLoadingConversation = false
    @Published var errorMessage: String?

    private let api: APIClientProtocol
    let userId: Int
    let userRole: String
    private var pollTimer: Timer?
    private var driverNameCache: [Int: String] = [:]
    private var companyNameCache: [Int: String] = [:]
    private var campaignNameCache: [Int: String] = [:]
    // Currently-open thread; poll tick reloads its conversation in place.
    var activeThread: MessageThread?

    // Driver and company id spaces are independent, so id+role must both match.
    func isMine(_ m: Message) -> Bool {
        m.senderId == userId && m.senderRole == userRole
    }

    init(userId: Int, userRole: String = "DRIVER", api: APIClientProtocol = APIClient.shared) {
        self.userId = userId
        self.userRole = userRole
        self.api = api
    }

    func loadInbox() async { await loadThreads() }

    func loadThreads() async {
        if threads.isEmpty { isLoading = true }
        defer { isLoading = false }

        do {
            let endpoint = Endpoint(path: "api/messages/all/\(userId)")
            let msgs: [Message] = try await api.send(endpoint)

            await resolveOtherNames(in: msgs)
            await resolveCampaignNames(in: msgs)

            var map: [String: MessageThread] = [:]
            for m in msgs {
                let mine = isMine(m)
                let otherId = mine ? m.recipientId : m.senderId
                let otherRole = mine ? m.recipientRole : m.senderRole
                let key = "\(m.campaignId)-\(otherRole)-\(otherId)"
                if let existing = map[key] {
                    if m.createdAt > existing.latest.createdAt {
                        map[key] = MessageThread(
                            id: key,
                            campaignId: m.campaignId,
                            campaignName: existing.campaignName,
                            otherId: otherId,
                            otherRole: otherRole,
                            otherName: existing.otherName,
                            latest: m,
                            unreadCount: existing.unreadCount,
                            subject: m.subject
                        )
                    }
                } else {
                    map[key] = MessageThread(
                        id: key,
                        campaignId: m.campaignId,
                        campaignName: campaignNameCache[m.campaignId] ?? "Campaign",
                        otherId: otherId,
                        otherRole: otherRole,
                        otherName: nameFor(id: otherId, role: otherRole),
                        latest: m,
                        unreadCount: 0,
                        subject: m.subject
                    )
                }
            }
            // Unread is only incoming-and-unread; my own outgoing never counts.
            for m in msgs where !m.isRead && !isMine(m) {
                let otherId = m.senderId
                let otherRole = m.senderRole
                let key = "\(m.campaignId)-\(otherRole)-\(otherId)"
                if var t = map[key] {
                    t = MessageThread(
                        id: t.id, campaignId: t.campaignId, campaignName: t.campaignName,
                        otherId: t.otherId, otherRole: t.otherRole, otherName: t.otherName,
                        latest: t.latest, unreadCount: t.unreadCount + 1,
                        subject: t.subject
                    )
                    map[key] = t
                }
            }

            let arr: [MessageThread] = Array(map.values)
            self.threads = arr.sorted { (a: MessageThread, b: MessageThread) in
                a.latest.createdAt > b.latest.createdAt
            }
            self.unreadCount = msgs.filter { !$0.isRead && !self.isMine($0) }.count
        } catch {
            if error.isCancellation { return }
            self.errorMessage = error.localizedDescription
        }
    }

    func loadConversation(_ thread: MessageThread, markRead: Bool = true) async {
        // Caller (view .task) owns activeThread; we only abort writes if it
        // changes mid-flight. Query goes via queryItems — path-encoding mangles "?"/"&".
        isLoadingConversation = true
        defer { isLoadingConversation = false }
        do {
            let endpoint = Endpoint(
                path: "api/messages/conversation",
                queryItems: [
                    URLQueryItem(name: "campaignId", value: "\(thread.campaignId)"),
                    URLQueryItem(name: "userId1", value: "\(userId)"),
                    URLQueryItem(name: "userId2", value: "\(thread.otherId)")
                ]
            )
            let msgs: [Message] = try await api.send(endpoint)
            guard self.activeThread?.id == thread.id else { return }
            self.conversation = msgs.sorted { $0.createdAt < $1.createdAt }

            if markRead {
                let unread = msgs.filter { !$0.isRead && !self.isMine($0) }
                if !unread.isEmpty {
                    for m in unread {
                        await markAsReadIgnoringErrors(m)
                    }
                    await loadThreads()
                }
            }
        } catch {
            if error.isCancellation { return }
            self.errorMessage = error.localizedDescription
        }
    }

    // Called from ConversationView.onDisappear.
    func clearActiveThread() {
        activeThread = nil
        conversation = []
    }

    func startPolling(interval: TimeInterval = 15) {
        stopPolling()
        pollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.loadThreads()
                if let active = self.activeThread {
                    await self.loadConversation(active, markRead: true)
                }
            }
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    func markAsRead(_ message: Message) async {
        guard !message.isRead else { return }
        await markAsReadIgnoringErrors(message)
        await loadThreads()
    }

    private func markAsReadIgnoringErrors(_ message: Message) async {
        do {
            let endpoint = Endpoint(
                path: "api/messages/\(message.id)/read",
                method: .patch
            )
            try await api.send(endpoint)
        } catch {
            // Non-critical; the next poll retries.
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
            if error.isCancellation { return false }
            errorMessage = error.localizedDescription
            return false
        }
    }

    func nameFor(id: Int, role: String) -> String {
        if role == "DRIVER" {
            return driverNameCache[id] ?? "Driver"
        }
        if role == "COMPANY" {
            return companyNameCache[id] ?? "Company"
        }
        return "User"
    }

    private func resolveOtherNames(in msgs: [Message]) async {
        var driverIds = Set<Int>()
        var companyIds = Set<Int>()
        for m in msgs {
            let mine = isMine(m)
            let otherId = mine ? m.recipientId : m.senderId
            let otherRole = mine ? m.recipientRole : m.senderRole
            if otherRole == "DRIVER", driverNameCache[otherId] == nil {
                driverIds.insert(otherId)
            } else if otherRole == "COMPANY", companyNameCache[otherId] == nil {
                companyIds.insert(otherId)
            }
        }
        for did in driverIds {
            if let name = await fetchDriverName(did) {
                driverNameCache[did] = name
            }
        }
        for cid in companyIds {
            if let name = await fetchCompanyName(cid) {
                companyNameCache[cid] = name
            }
        }
    }

    private func resolveCampaignNames(in msgs: [Message]) async {
        let ids = Set(msgs.map { $0.campaignId }).filter { campaignNameCache[$0] == nil }
        for cid in ids {
            if let name = await fetchCampaignName(cid) {
                campaignNameCache[cid] = name
            }
        }
    }

    private func fetchCampaignName(_ id: Int) async -> String? {
        do {
            let endpoint = Endpoint(path: "api/campaigns/\(id)")
            let campaign: Campaign = try await api.send(endpoint)
            return campaign.name
        } catch {
            return nil
        }
    }

    private func fetchDriverName(_ id: Int) async -> String? {
        do {
            let endpoint = Endpoint(path: "api/drivers/\(id)")
            let driver: Driver = try await api.send(endpoint)
            return driver.name
        } catch {
            return nil
        }
    }

    private func fetchCompanyName(_ id: Int) async -> String? {
        do {
            let endpoint = Endpoint(path: "api/companies/\(id)")
            let company: Company = try await api.send(endpoint)
            return company.name
        } catch {
            return nil
        }
    }
}
