import Foundation
import UIKit
import PhotosUI
import SwiftUI

@MainActor
class CreateCampaignViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var startDate = Date()
    @Published var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @Published var budget = ""
    @Published var maxDrivers = ""
    @Published var ratePerKm = "0.10"
    @Published var estimatedReach = ""
    @Published var selectedImages: [UIImage] = []
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var didCreate = false

    static let maxImages = 5

    private let api: APIClient
    private let companyId: Int

    init(companyId: Int, api: APIClient = .shared) {
        self.companyId = companyId
        self.api = api
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(budget) != nil && Double(budget)! > 0 &&
        Int(maxDrivers) != nil && Int(maxDrivers)! > 0 &&
        Double(ratePerKm) != nil && Double(ratePerKm)! > 0 &&
        endDate > startDate
    }

    func removeImage(at index: Int) {
        guard selectedImages.indices.contains(index) else { return }
        selectedImages.remove(at: index)
    }

    func loadImages(from selections: [PhotosPickerItem]) {
        let remaining = Self.maxImages - selectedImages.count
        let toLoad = Array(selections.prefix(remaining))
        for item in toLoad {
            item.loadTransferable(type: Data.self) { [weak self] result in
                DispatchQueue.main.async {
                    if case .success(let data?) = result,
                       let image = UIImage(data: data) {
                        self?.selectedImages.append(image)
                    }
                }
            }
        }
    }

    func createCampaign() async {
        guard isValid else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"

        do {
            let request = CreateCampaignRequest(
                name: name,
                description: description,
                companyId: companyId,
                startDate: fmt.string(from: startDate),
                endDate: fmt.string(from: endDate),
                budget: Double(budget) ?? 0,
                maxDrivers: Int(maxDrivers) ?? 0,
                ratePerKm: Double(ratePerKm) ?? 0,
                estimatedReach: Int(estimatedReach),
                status: "RECRUITING"
            )
            let body = try JSONEncoder().encode(request)
            let endpoint = Endpoint(path: "api/campaigns", method: .post, body: body)
            let campaign: Campaign = try await api.send(endpoint)

            if !selectedImages.isEmpty {
                let imageDataList = selectedImages.compactMap { image in
                    image.jpegData(compressionQuality: 0.7)
                }
                if !imageDataList.isEmpty {
                    _ = try await api.uploadImages(campaignId: campaign.id, images: imageDataList)
                }
            }

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
    let startDate: String
    let endDate: String
    let budget: Double
    let maxDrivers: Int
    let ratePerKm: Double
    let estimatedReach: Int?
    let status: String
}
