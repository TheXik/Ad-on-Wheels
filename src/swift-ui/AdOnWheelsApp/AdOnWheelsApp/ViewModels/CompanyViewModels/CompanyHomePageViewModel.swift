import Foundation

@MainActor
class CompanyHomePageViewModel: ObservableObject {
    
    @Published var company: [Company] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api: APIClientProtocol

    init(api: APIClientProtocol = APIClient.shared) {
        self.api = api
    }

    func fetchCompanies() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }

        do {
        
            let endpoint = Endpoint(path: "companies")
            let fetchedCompanies: [Company] = try await api.send(endpoint)
            self.company = fetchedCompanies
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
