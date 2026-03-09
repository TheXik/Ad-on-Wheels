import SwiftUI

struct Campaign: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let description: String
    let companyId: Int
}


