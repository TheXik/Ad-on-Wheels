import SwiftUI

struct SplashScreenView: View {
    var onFinished: () -> Void

    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.orange.opacity(0.3),
                                    Color.blue.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 60,
                                endRadius: 180
                            )
                        )
                        .frame(width: 360, height: 360)
                        .opacity(glowOpacity)

                    Image("SplashLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
                        .shadow(color: Color.blue.opacity(0.4), radius: 30, x: 0, y: 10)
                        .shadow(color: Color.orange.opacity(0.3), radius: 20, x: 0, y: -5)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 8) {
                    Text("Ad on Wheels")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text("Drive. Earn. Advertise.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .opacity(taglineOpacity)
                }
                .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                glowOpacity = 1.0
            }

            withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                textOpacity = 1.0
            }

            withAnimation(.easeIn(duration: 0.4).delay(0.8)) {
                taglineOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onFinished()
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(onFinished: {})
}
