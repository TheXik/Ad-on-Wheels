import SwiftUI

struct VerificationCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isTakingPhoto = false
    @State private var photoTaken = false
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if photoTaken {
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
            } else {
                VStack {
                    // Camera Header
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
                    
                    // Camera Placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            .frame(height: 400)
                        
                        Text("Align passenger side decal here")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Shutter Button
                    Button(action: takePhoto) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.2), lineWidth: 4)
                            )
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    func takePhoto() {
        withAnimation {
            isTakingPhoto = true
        }
        
        // Simulate network/upload delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                photoTaken = true
            }
            
            // Close after success message
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct VerificationCameraView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationCameraView(onComplete: {})
    }
}
