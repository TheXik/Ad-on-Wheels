import Foundation

@MainActor
class DriverHomePageViewModel: ObservableObject {

    @Published var homePageData: DriverHomePageResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    init(api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.api = api
        self.authService = authService
    }

    func fetchDriverHomePage() async {
        guard let driverId = authService.userId else {
            errorMessage = "Driver ID not found"
            return
        }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let endpoint = Endpoint(path: "api/drivers/\(driverId)/home")
            let response: DriverHomePageResponse = try await api.send(endpoint)
            self.homePageData = response

        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
