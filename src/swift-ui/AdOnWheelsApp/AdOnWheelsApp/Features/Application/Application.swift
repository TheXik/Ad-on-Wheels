import SwiftUI

struct Application: Identifiable, Codable {
    let id: Int
    let campaignId: Int
    let driverId: Int
    let status: String // applied, accepted, declined
} 