import SwiftUI

struct QRScanView: View {
    var onScanComplete: () -> Void

    /// Optional: when provided, enables UC013 deferred ride flow
    var rideViewModel: RideViewModel?

    @State private var isScanning = true
    @State private var progress: CGFloat = 0.0
    @State private var showDeferredPrompt = false
    @State private var deferredSuccess = false

    /// Whether this is a deferred scan (no active ride, but GPS data available)
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
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                progress = 1.0
            }
        }
    }

    // MARK: - Scanning View

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

            // Mock Camera Viewfinder
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 250, height: 250)

                // Scanning animation line
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 240, height: 2)
                    .offset(y: -120 + (progress * 240))
            }

            Spacer()

            // Simulate Scan Button
            Button("Simulate Scan") {
                completeScan()
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.white)
        }
        .padding(.vertical, 50)
    }

    // MARK: - UC013 Deferred Ride Prompt

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
                    // Discard buffered data and return
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

    // MARK: - Deferred Ride Success

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

    // MARK: - Normal Success View

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

    // MARK: - Actions

    func completeScan() {
        withAnimation {
            isScanning = false
            // UC013: If no active ride but GPS data exists, show deferred prompt
            if isDeferredScan {
                showDeferredPrompt = true
            }
        }
    }
}

struct QRScanView_Previews: PreviewProvider {
    static var previews: some View {
        QRScanView {}
    }
}
