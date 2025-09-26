
import Foundation


@MainActor
class LoginDriverViewModel: ObservableObject{
    
    @Published var email : String = ""
    @Published var password : String = ""
    @Published var isLoading : Bool = false
    @Published var errorMessage : String?
    
    private let api: APIClientProtocol
    
    init(api: APIClientProtocol = APIClient.shared)
    {
        self.api = api
    }
    
    
    func login() async -> String? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let endpoint = Endpoint(
                path: "auth/login",
                method: .post,
                body: try JSONEncoder().encode(["email": email, "password": password])
            )
            let response: LoginResponse = try await api.send(endpoint)
            return response.token
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

