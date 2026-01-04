
import Foundation


@MainActor
class LoginDriverViewModel: ObservableObject{
    
    @Published var email : String = ""
    @Published var password : String = ""
    @Published var isLoading : Bool = false
    @Published var errorMessage : String?
    @Published var fieldErrors: [String: String] = [:]
    
    private let api: APIClientProtocol
    
    init(api: APIClientProtocol = APIClient.shared)
    {
        self.api = api
    }
    
    
    func login() async -> String? {
        isLoading = true
        errorMessage = nil
        fieldErrors = [:]
        defer { isLoading = false }
        
        do {
            let endpoint = Endpoint(
                path: "auth/login",
                method: .post,
                body: try JSONEncoder().encode(["email": email, "password": password])
            )
            let response: LoginResponse = try await api.sendMapped(endpoint)
            return response.token
        } catch {
            if let appError = error as? AppError, case .validation(let errors) = appError {
                self.fieldErrors = errors
                self.errorMessage = "Please fix the errors below."
            } else {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }
}

