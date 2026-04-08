import SwiftUI

struct OnboardingVehicleStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("Your Vehicle")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Tell us about your car")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 0) {
                        OnboardingTextField(label: "Make", text: $viewModel.vehicleMake, placeholder: "e.g. Toyota")
                        Divider()
                        OnboardingTextField(label: "Model", text: $viewModel.vehicleModel, placeholder: "e.g. Corolla")
                        Divider()
                        OnboardingTextField(label: "Year", text: $viewModel.vehicleYear, placeholder: "e.g. 2020", keyboardType: .numberPad)
                        Divider()
                        OnboardingTextField(label: "License Plate", text: $viewModel.vehiclePlate, placeholder: "e.g. AB 123 CD", autocapitalization: .characters)
                    }
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal, 24)
                }
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
                    viewModel.nextStep()
                } label: {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.vehicleFormValid ? brandBlue : Color.gray.opacity(0.3))
                        .foregroundColor(viewModel.vehicleFormValid ? .white : .gray)
                        .cornerRadius(14)
                }
                .disabled(!viewModel.vehicleFormValid)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

private struct OnboardingTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization? = nil

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
                .frame(width: 110, alignment: .leading)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }
}
