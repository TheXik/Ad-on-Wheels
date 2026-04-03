import SwiftUI

struct DriverOnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(driverName: String, authService: AuthenticationService, onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(driverName: driverName, authService: authService))
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.currentStep >= 1 && viewModel.currentStep <= 3 {
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }

            Group {
                switch viewModel.currentStep {
                case 0:
                    OnboardingWelcomeStep(viewModel: viewModel)
                case 1:
                    OnboardingVehicleStep(viewModel: viewModel)
                case 2:
                    OnboardingPhotoStep(viewModel: viewModel)
                case 3:
                    OnboardingGoalStep(viewModel: viewModel)
                default:
                    OnboardingCompleteStep(onStart: onComplete)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(1...viewModel.totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= viewModel.currentStep ? brandBlue : Color.gray.opacity(0.25))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            }
        }
    }
}
