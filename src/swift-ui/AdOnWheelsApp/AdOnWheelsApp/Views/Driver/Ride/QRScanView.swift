import SwiftUI

struct QRScanView: View {
    var onScanComplete: () -> Void
    
    @State private var isScanning = true
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if isScanning {
                VStack(spacing: 20) {
                    Text("San QR Code on Car")
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
                    
                    // Simulate Scan Button (or auto)
                    Button("Simulate Scan") {
                       completeScan()
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
                .padding(.vertical, 50)
            } else {
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
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
                progress = 1.0
            }
        }
    }
    
    func completeScan() {
        withAnimation {
            isScanning = false
        }
    }
}

struct QRScanView_Previews: PreviewProvider {
    static var previews: some View {
        QRScanView {}
    }
}
