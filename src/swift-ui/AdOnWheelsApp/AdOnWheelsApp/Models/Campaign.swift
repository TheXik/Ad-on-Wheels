import Foundation

struct Campaign: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let description: String
    let companyId: Int
    let startDate: String
    let endDate: String
    let budget: Double
    let maxDrivers: Int
    let estimatedReach: Int?
    let status: String

    var isActive: Bool {
        status == "RECRUITING" || status == "ACTIVE"
    }

    var formattedDateRange: String {
        let inFmt = DateFormatter()
        inFmt.dateFormat = "yyyy-MM-dd"
        let outFmt = DateFormatter()
        outFmt.dateFormat = "d.M.yyyy"

        let start = inFmt.date(from: startDate).map { outFmt.string(from: $0) } ?? startDate
        let end = inFmt.date(from: endDate).map { outFmt.string(from: $0) } ?? endDate
        return "\(start) – \(end)"
    }

    var formattedBudget: String {
        String(format: "€ %.0f", budget)
    }

    var formattedReach: String {
        guard let reach = estimatedReach else { return "—" }
        if reach >= 1000 {
            return "\(reach / 1000)k people"
        }
        return "\(reach) people"
    }
}


