import SwiftUI

struct OnboardingCompleteStep: View {
    let onStart: () -> Void

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    @State private var showCheckmark = false
    @State private var showText = false
    @State private var showButton = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(showCheckmark ? 1 : 0.3)

                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .scaleEffect(showCheckmark ? 1 : 0)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCheckmark)

            VStack(spacing: 10) {
                Text("You're all set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .opacity(showText ? 1 : 0)

                Text("Start driving and earning today")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .opacity(showText ? 1 : 0)
            }
            .animation(.easeIn(duration: 0.4).delay(0.3), value: showText)

            Spacer()

            Button {
                onStart()
            } label: {
                Text("Start Driving")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(brandBlue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(showButton ? 1 : 0)
            .offset(y: showButton ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(0.5), value: showButton)
        }
        .onAppear {
            showCheckmark = true
            showText = true
            showButton = true
        }
    }
}
