import Foundation

struct Ride: Identifiable, Codable {
    let id: Int
    let driverId: Int
    let campaignId: Int?
    let startTime: String
    let endTime: String?
    let startLocation: String?
    let endLocation: String?
    let duration: Int?          // Duration in seconds (matches backend field name)
    let qrCodeData: String?
    let status: String          // ACTIVE, COMPLETED, VERIFIED, CANCELLED
}
