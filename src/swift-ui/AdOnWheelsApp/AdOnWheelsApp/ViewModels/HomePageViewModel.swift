import Foundation

@MainActor
class HomePageViewModel: ObservableObject {
    
    @Published var drivers: [Driver] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api: APIClientProtocol

    init(api: APIClientProtocol = APIClient.shared) {
        self.api = api
    }

    func fetchDrivers() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }

        do {
        
            let endpoint = Endpoint(path: "drivers")
            let fetchedDrivers: [Driver] = try await api.send(endpoint)
            self.drivers = fetchedDrivers
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
