import Foundation

struct RegistrationResponse: Decodable {
    let token: String
    let message: String
}
