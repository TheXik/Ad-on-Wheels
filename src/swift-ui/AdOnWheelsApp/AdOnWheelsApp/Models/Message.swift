import Foundation

struct Message: Identifiable, Codable {
    let id: Int
    let campaignId: Int
    let senderId: Int
    let senderRole: String
    let recipientId: Int
    let recipientRole: String
    let subject: String
    let body: String
    let isRead: Bool
    let createdAt: String

    var relativeDate: String {
        let dateStr = String(createdAt.prefix(10))
        let today = formatDate(Date())
        let yesterday = formatDate(Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())

        if dateStr == today { return "Today" }
        if dateStr == yesterday { return "Yesterday" }
        return dateStr
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    var preview: String {
        if body.count <= 80 { return body }
        return String(body.prefix(80)) + "..."
    }
}

struct SendMessageRequest: Encodable {
    let campaignId: Int
    let senderId: Int
    let senderRole: String
    let recipientId: Int
    let recipientRole: String
    let subject: String
    let body: String
}
