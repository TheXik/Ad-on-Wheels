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

    // Backend sends LocalDateTime without timezone. JVM in Docker is UTC.
    // Append Z and format in Europe/Prague.
    private static let pragueTimeZone = TimeZone(identifier: "Europe/Prague") ?? .current

    private static let isoUTCFormatters: [ISO8601DateFormatter] = {
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let withoutFractional = ISO8601DateFormatter()
        withoutFractional.formatOptions = [.withInternetDateTime]
        return [withFractional, withoutFractional]
    }()

    private var date: Date? {
        let trimmed = createdAt.contains("Z") || createdAt.contains("+") ? createdAt : createdAt + "Z"
        for formatter in Self.isoUTCFormatters {
            if let d = formatter.date(from: trimmed) { return d }
        }
        return nil
    }

    private static func dateFormatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = format
        f.timeZone = pragueTimeZone
        f.locale = Locale(identifier: "en_GB")
        return f
    }

    var relativeDate: String {
        guard let d = date else { return String(createdAt.prefix(10)) }
        var pragueCal = Calendar(identifier: .gregorian)
        pragueCal.timeZone = Self.pragueTimeZone
        if pragueCal.isDateInToday(d) { return "Today" }
        if pragueCal.isDateInYesterday(d) { return "Yesterday" }
        return Self.dateFormatter("yyyy-MM-dd").string(from: d)
    }

    var formattedDateTime: String {
        guard let d = date else { return createdAt }
        return Self.dateFormatter("d.M.yyyy, HH:mm").string(from: d)
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
