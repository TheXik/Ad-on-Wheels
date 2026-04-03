import SwiftUI

struct OnboardingGoalStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    private let presets: [(value: Double, label: String, subtitle: String)] = [
        (100, "100 km", "Casual"),
        (200, "200 km", "Regular"),
        (500, "500 km", "Active"),
        (1000, "1000 km", "Pro")
    ]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("Monthly Goal")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("How many kilometers do you want to drive each month?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)

                    Text("\(Int(viewModel.monthlyGoalKm)) km")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(brandBlue)
                        .contentTransition(.numericText())

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(presets, id: \.value) { preset in
                            goalCard(preset)
                        }
                    }
                    .padding(.horizontal, 24)

                    Text("Drivers who set goals earn more on average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .frame(width: 50, height: 50)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                }

                Button {
                    Task { await viewModel.completeOnboarding() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Finish Setup")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(brandBlue)
                .foregroundColor(.white)
                .cornerRadius(14)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private func goalCard(_ preset: (value: Double, label: String, subtitle: String)) -> some View {
        let isSelected = viewModel.monthlyGoalKm == preset.value

        VStack(spacing: 6) {
            Text(preset.label)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .white : .primary)

            Text(preset.subtitle)
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(isSelected ? brandBlue : Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? brandBlue : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.monthlyGoalKm = preset.value
            }
        }
    }
}
