import SwiftUI
import AVFoundation

struct QRScanView: View {
    var onScanComplete: () -> Void

    var rideViewModel: RideViewModel?

    @State private var isScanning = true
    @State private var showDeferredPrompt = false
    @State private var deferredSuccess = false
    @State private var cameraPermission: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var showPermissionDenied = false

    private var isDeferredScan: Bool {
        guard let vm = rideViewModel else { return false }
        return vm.currentRideId == nil && vm.hasDeferredRideData
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            if isScanning {
                scanningView
            } else if showDeferredPrompt {
                deferredPromptView
            } else if deferredSuccess {
                deferredSuccessView
            } else {
                successView
            }
        }
        .onAppear {
            requestCameraAccess()
        }
        .alert("Camera Access Required", isPresented: $showPermissionDenied) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow camera access in Settings to scan QR codes.")
        }
    }

    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermission = .authorized
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermission = granted ? .authorized : .denied
                    if !granted { showPermissionDenied = true }
                }
            }
        default:
            showPermissionDenied = true
        }
    }

    private var scanningView: some View {
        VStack(spacing: 20) {
            Text("Scan QR Code on Car")
                .font(.headline)
                .foregroundColor(.white)

            Text("Align the QR code within the frame to verify vehicle.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            if cameraPermission == .authorized {
                QRCameraPreview { _ in
                    completeScan()
                }
                .frame(width: 280, height: 280)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                )
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 250, height: 250)

                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("Camera access needed")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            #if DEBUG
            Button("Skip Scan (Dev)") {
                completeScan()
            }
            .font(.footnote.bold())
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.orange.opacity(0.8))
            .cornerRadius(8)
            .foregroundColor(.black)
            #endif
        }
        .padding(.vertical, 50)
    }


    private var deferredPromptView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)

            Text("No Start Scan Found")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("We detected GPS data from your recent drive. Would you like to use the tracked GPS data as your ride?")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            if let vm = rideViewModel {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.blue)
                        Text("\(vm.gpsBuffer.count) GPS points recorded")
                            .foregroundColor(.white)
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }

            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        await rideViewModel?.submitDeferredRide()
                        withAnimation {
                            showDeferredPrompt = false
                            deferredSuccess = true
                        }
                    }
                }) {
                    Text("Yes, Log This Ride")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(15)
                }

                Button(action: {
                    rideViewModel?.discardDeferredBuffer()
                    onScanComplete()
                }) {
                    Text("No, Discard")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
        }
    }


    private var deferredSuccessView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Ride Logged!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Your drive was reconstructed from GPS data and saved successfully.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            if let vm = rideViewModel {
                VStack(spacing: 8) {
                    HStack {
                        Text("Distance:")
                            .foregroundColor(.gray)
                        Text(String(format: "%.2f km", vm.distanceTravelled))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    HStack {
                        Text("Duration:")
                            .foregroundColor(.gray)
                        Text(vm.timeString)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .font(.subheadline)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }

            Button(action: onScanComplete) {
                Text("Back to Dashboard")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }


    private var successView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Ride Verified!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Button(action: onScanComplete) {
                Text("Back to Dashboard")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }

    func completeScan() {
        withAnimation {
            isScanning = false
            if isDeferredScan {
                showDeferredPrompt = true
            } else if let vm = rideViewModel, let rideId = vm.lastCompletedRideId {
                Task { await vm.verifyRide(completedRideId: rideId) }
            }
        }
    }
}

struct QRCameraPreview: UIViewRepresentable {
    var onCodeScanned: (String) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let session = AVCaptureSession()
        context.coordinator.session = session

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return view }

        if session.canAddInput(input) { session.addInput(input) }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
            output.metadataObjectTypes = [.qr]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.session?.stopRunning()
    }

    func makeCoordinator() -> Coordinator { Coordinator(onCodeScanned: onCodeScanned) }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var session: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        var onCodeScanned: (String) -> Void
        private var hasScanned = false

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard !hasScanned,
                  let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = object.stringValue else { return }
            hasScanned = true
            session?.stopRunning()
            onCodeScanned(value)
        }
    }
}
