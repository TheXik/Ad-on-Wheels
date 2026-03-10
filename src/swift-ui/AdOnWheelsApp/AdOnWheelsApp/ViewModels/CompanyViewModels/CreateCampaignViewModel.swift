import Foundation

@MainActor
class CreateCampaignViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var startDate = Date()
    @Published var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @Published var budget = ""
    @Published var maxDrivers = ""
    @Published var estimatedReach = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var didCreate = false

    private let api: APIClientProtocol
    private let companyId: Int

    init(companyId: Int, api: APIClientProtocol = APIClient.shared) {
        self.companyId = companyId
        self.api = api
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(budget) != nil && Double(budget)! > 0 &&
        Int(maxDrivers) != nil && Int(maxDrivers)! > 0 &&
        endDate > startDate
    }

    func createCampaign() async {
        guard isValid else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"

        do {
            let request = CreateCampaignRequest(
                name: name,
                description: description,
                companyId: companyId,
                startDate: fmt.string(from: startDate),
                endDate: fmt.string(from: endDate),
                budget: Double(budget) ?? 0,
                maxDrivers: Int(maxDrivers) ?? 0,
                estimatedReach: Int(estimatedReach),
                status: "RECRUITING"
            )
            let body = try JSONEncoder().encode(request)
            let endpoint = Endpoint(path: "api/campaigns", method: .post, body: body)
            let _: Campaign = try await api.send(endpoint)
            didCreate = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct CreateCampaignRequest: Encodable {
    let name: String
    let description: String
    let companyId: Int
    let startDate: String
    let endDate: String
    let budget: Double
    let maxDrivers: Int
    let estimatedReach: Int?
    let status: String
}
