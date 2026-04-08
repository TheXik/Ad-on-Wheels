import SwiftUI
import UIKit
import AVFoundation

struct VerificationCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var isUploading = false
    @State private var uploadSuccess = false
    @State private var errorMessage: String?
    @State private var showPermissionDenied = false

    var driverId: Int
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            if uploadSuccess {
                successView
            } else if let image = capturedImage {
                reviewView(image: image)
            } else {
                promptView
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $capturedImage)
        }
        .alert("Camera Access Required", isPresented: $showPermissionDenied) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow camera access in Settings to complete your weekly verification.")
        }
    }

    private var promptView: some View {
        VStack(spacing: 24) {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()

            Spacer()

            Image(systemName: "camera.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.6))

            Text("Take a photo of the\npassenger side decal")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Button(action: { requestCameraAccess() }) {
                Text("Open Camera")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(14)
            }

            Spacer()
        }
    }

    private func reviewView(image: UIImage) -> some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { capturedImage = nil }) {
                    Text("Retake")
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(16)
                .padding(.horizontal)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Button(action: { Task { await uploadPhoto(image) } }) {
                if isUploading {
                    ProgressView()
                        .tint(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                } else {
                    Text("Submit Verification")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                }
            }
            .background(Color.white)
            .cornerRadius(14)
            .disabled(isUploading)

            Spacer()
        }
    }

    private var successView: some View {
        VStack {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding()
            Text("Verification Uploaded!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
        }
        .transition(.scale)
    }

    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { showCamera = true } else { showPermissionDenied = true }
                }
            }
        default:
            showPermissionDenied = true
        }
    }

    private func uploadPhoto(_ image: UIImage) async {
        isUploading = true
        errorMessage = nil
        defer { isUploading = false }

        guard let jpegData = image.jpegData(compressionQuality: 0.5) else {
            errorMessage = "Failed to compress image"
            return
        }

        let base64 = jpegData.base64EncodedString()

        do {
            let endpoint = Endpoint(
                path: "api/drivers/\(driverId)/verify-decal",
                method: .post,
                queryItems: [URLQueryItem(name: "photoBase64", value: base64)]
            )
            let _: Driver = try await APIClient.shared.send(endpoint)
            withAnimation { uploadSuccess = true }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            onComplete()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = "Upload failed. Try again."
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
