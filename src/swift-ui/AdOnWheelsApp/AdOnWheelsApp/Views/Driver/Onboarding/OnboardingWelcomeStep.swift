import SwiftUI

struct OnboardingWelcomeStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            ZStack {
                Circle()
                    .fill(brandBlue.opacity(0.1))
                    .frame(width: 160, height: 160)

                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(brandBlue)
            }

            VStack(spacing: 10) {
                Text("Hey \(viewModel.driverName)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Let's get you set up in just a few steps")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            Button {
                viewModel.nextStep()
            } label: {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(brandBlue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
