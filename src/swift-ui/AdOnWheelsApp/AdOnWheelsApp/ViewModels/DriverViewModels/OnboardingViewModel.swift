import SwiftUI
import PhotosUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0 // 0=welcome, 1=vehicle, 2=photo, 3=goal, 4=done

    // Vehicle fields
    @Published var vehicleMake = ""
    @Published var vehicleModel = ""
    @Published var vehicleYear = ""
    @Published var vehiclePlate = ""

    // Errors only surface after the first Continue tap on the vehicle step.
    @Published var vehicleFieldsTouched = false

    // Vehicle photo
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var vehicleImage: UIImage?

    // Goal
    @Published var monthlyGoalKm: Double = 200

    // State
    @Published var isLoading = false
    @Published var errorMessage: String?

    let driverName: String

    private let api: APIClientProtocol
    private let authService: AuthenticationService

    init(driverName: String, api: APIClientProtocol = APIClient.shared, authService: AuthenticationService) {
        self.driverName = driverName
        self.api = api
        self.authService = authService
    }

    var totalSteps: Int { 3 }

    // Per-field validation mirrors backend rules in OnboardingRequest.java.
    var makeError: String? {
        vehicleMake.trimmingCharacters(in: .whitespaces).isEmpty
            ? "Make is required" : nil
    }

    var modelError: String? {
        vehicleModel.trimmingCharacters(in: .whitespaces).isEmpty
            ? "Model is required" : nil
    }

    var yearError: String? {
        let trimmed = vehicleYear.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "Year is required" }
        guard trimmed.range(of: #"^\d{4}$"#, options: .regularExpression) != nil
        else { return "Year must be a 4-digit number" }
        let currentYear = Calendar.current.component(.year, from: Date())
        guard let y = Int(trimmed), (1900...currentYear + 1).contains(y)
        else { return "Enter a realistic year (1900–\(currentYear + 1))" }
        return nil
    }

    var plateError: String? {
        let trimmed = vehiclePlate.trimmingCharacters(in: .whitespaces).uppercased()
        if trimmed.isEmpty { return "License plate is required" }
        if trimmed.count < 2 || trimmed.count > 20 {
            return "License plate must be 2–20 characters"
        }
        guard trimmed.range(of: #"^[A-Z0-9 \-]+$"#, options: .regularExpression) != nil
        else { return "Use only letters, digits, spaces, and hyphens" }
        return nil
    }

    var vehicleFormValid: Bool {
        makeError == nil && modelError == nil && yearError == nil && plateError == nil
    }

    func loadSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            vehicleImage = image
        }
    }

    func clearVehiclePhoto() {
        vehicleImage = nil
        selectedPhotoItem = nil
    }

    func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep += 1
        }
    }

    func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = max(0, currentStep - 1)
        }
    }

    func completeOnboarding() async {
        guard let driverId = authService.userId else { return }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            var imageUrl: String?

            if let image = vehicleImage,
               let jpegData = image.jpegData(compressionQuality: 0.8) {
                imageUrl = try await uploadVehicleImage(driverId: driverId, imageData: jpegData)
            }

            var body: [String: Any] = [
                "make": vehicleMake.trimmingCharacters(in: .whitespaces),
                "model": vehicleModel.trimmingCharacters(in: .whitespaces),
                "year": vehicleYear.trimmingCharacters(in: .whitespaces),
                "licensePlate": vehiclePlate.trimmingCharacters(in: .whitespaces).uppercased(),
                "monthlyGoalKm": monthlyGoalKm
            ]

            if let imageUrl = imageUrl {
                body["vehicleImageUrl"] = imageUrl
            }

            let jsonData = try JSONSerialization.data(withJSONObject: body)

            let endpoint = Endpoint(
                path: "api/drivers/\(driverId)/onboarding",
                method: .patch,
                body: jsonData
            )

            let _: Driver = try await api.send(endpoint)

            UserDefaults.standard.set(monthlyGoalKm, forKey: "monthlyGoalKm")

            nextStep()
        } catch let NetworkError.serverError(response) {
            if let fieldErrors = response.validationErrors, !fieldErrors.isEmpty {
                // Surface server-side validation errors inline on the vehicle step.
                vehicleFieldsTouched = true
                let vehicleFieldKeys = ["make", "model", "year", "licensePlate"]
                if vehicleFieldKeys.contains(where: { fieldErrors[$0] != nil }) {
                    currentStep = 1
                }
                errorMessage = fieldErrors.values.joined(separator: "\n")
            } else {
                errorMessage = response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func uploadVehicleImage(driverId: Int, imageData: Data) async throws -> String {
        let boundary = UUID().uuidString
        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"vehicle.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let endpoint = Endpoint(
            path: "api/drivers/\(driverId)/vehicle-image",
            method: .post,
            headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)"],
            body: body
        )

        struct ImageUploadResponse: Decodable {
            let imageUrl: String
        }

        let response: ImageUploadResponse = try await api.send(endpoint)
        return response.imageUrl
    }
}
