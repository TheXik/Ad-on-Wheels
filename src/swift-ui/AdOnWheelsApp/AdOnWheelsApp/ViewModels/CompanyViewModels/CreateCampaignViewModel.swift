import Foundation

@MainActor
class CreateCampaignViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
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
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func createCampaign() async {
        guard isValid else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            let body = try JSONEncoder().encode(
                CreateCampaignRequest(name: name, description: description, companyId: companyId)
            )
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
}
