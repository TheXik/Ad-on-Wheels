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
    let ratePerKm: Double?
    let estimatedReach: Int?
    let status: String
    let imageUrls: [String]?
    var companyName: String?

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

    var resolvedImageUrls: [URL] {
        guard let urls = imageUrls else { return [] }
        return urls.compactMap { path in
            if path.hasPrefix("http") {
                return URL(string: path)
            }
            let normalized = path.hasPrefix("/") ? String(path.dropFirst()) : path
            return AppConfig.baseURL.appendingPathComponent(normalized)
        }
    }

    var formattedBudget: String {
        String(format: "€ %.0f", budget)
    }

    var formattedRatePerKm: String {
        guard let rate = ratePerKm else { return "-" }
        return String(format: "€ %.2f / km", rate)
    }

    var formattedReach: String {
        guard let reach = estimatedReach else { return "-" }
        if reach >= 1000 {
            return "\(reach / 1000)k people"
        }
        return "\(reach) people"
    }
}


