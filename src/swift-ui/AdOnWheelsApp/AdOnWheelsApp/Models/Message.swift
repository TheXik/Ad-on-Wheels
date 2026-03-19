import Foundation

struct Message: Identifiable, Codable {
    let id: Int
    let campaignId: Int
    let senderId: Int
    let senderRole: String  // "DRIVER" or "COMPANY"
    let recipientId: Int
    let subject: String
    let body: String
    let isRead: Bool
    let createdAt: String   // ISO-8601 from backend

    /// Formatted relative date for display
    var relativeDate: String {
        // Simple formatting — shows the date portion
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

    /// Preview text (first 80 chars of body)
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
    let subject: String
    let body: String
}
