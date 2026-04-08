import SwiftUI

struct VehicleView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var isEditing = false
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var plate = ""
    @State private var color = ""

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "car.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)

                    if isEditing {
                        editForm
                    } else if viewModel.hasVehicle {
                        vehicleInfo
                    } else {
                        noVehicle
                    }
                }
                .padding(.top)
            }
        }
        .navigationBarTitle("My Vehicle")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Cancel" : (viewModel.hasVehicle ? "Edit" : "Add")) {
                    if isEditing {
                        isEditing = false
                    } else {
                        populateFields()
                        isEditing = true
                    }
                }
            }
        }
        .onChange(of: viewModel.vehicleSaveSuccess) { success in
            if success {
                isEditing = false
            }
        }
    }

    @ViewBuilder
    private var editForm: some View {
        VStack(spacing: 0) {
            VehicleFormField(label: "Make", text: $make, placeholder: "e.g. Toyota")
            Divider()
            VehicleFormField(label: "Model", text: $model, placeholder: "e.g. Corolla")
            Divider()
            VehicleFormField(label: "Year", text: $year, placeholder: "e.g. 2020", keyboardType: .numberPad)
            Divider()
            VehicleFormField(label: "License Plate", text: $plate, placeholder: "e.g. AB 123 CD", autocapitalization: .characters)
            Divider()
            VehicleFormField(label: "Color", text: $color, placeholder: "e.g. White")
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .padding(.horizontal)

        Button {
            Task {
                await viewModel.saveVehicle(
                    make: make, model: model, year: year,
                    plate: plate, color: color
                )
            }
        } label: {
            if viewModel.isSavingVehicle {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Save Vehicle")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(isFormValid ? Color.blue : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .disabled(!isFormValid || viewModel.isSavingVehicle)

        if let error = viewModel.errorMessage {
            Text(error)
                .font(.caption)
                .foregroundColor(.red)
                .padding(.horizontal)
        }
    }

    private var vehicleInfo: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                InfoRow(label: "Make", value: viewModel.vehicleMake)
                Divider()
                InfoRow(label: "Model", value: viewModel.vehicleModel)
                Divider()
                InfoRow(label: "Year", value: viewModel.vehicleYear)
                Divider()
                InfoRow(label: "License Plate", value: viewModel.vehiclePlate)
                Divider()
                InfoRow(label: "Color", value: viewModel.vehicleColor)
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(15)
            .padding(.horizontal)

            if viewModel.isVehicleVerified {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Verified Vehicle")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            } else {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                    Text("Pending Verification")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }

    private var noVehicle: some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)

            Text("No Vehicle Registered")
                .font(.headline)

            Text("Tap 'Add' to register your vehicle.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .padding(.horizontal)
    }

    private var isFormValid: Bool {
        !make.trimmingCharacters(in: .whitespaces).isEmpty &&
        !model.trimmingCharacters(in: .whitespaces).isEmpty &&
        !year.trimmingCharacters(in: .whitespaces).isEmpty &&
        !plate.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func populateFields() {
        make = viewModel.vehicleMake
        model = viewModel.vehicleModel
        year = viewModel.vehicleYear
        plate = viewModel.vehiclePlate
        color = viewModel.vehicleColor
    }
}

private struct VehicleFormField: View {
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

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).foregroundColor(.gray)
            Spacer()
            Text(value).fontWeight(.medium)
        }
        .padding()
    }
}
