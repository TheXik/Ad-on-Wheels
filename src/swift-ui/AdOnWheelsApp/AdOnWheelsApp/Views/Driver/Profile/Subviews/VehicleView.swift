import SwiftUI

struct VehicleView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Car Image
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                
                if viewModel.hasVehicle {
                    // Display Mode - Info List
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
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding()
                    
                    // Status Badge
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
                } else {
                    // No Vehicle Registered
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("No Vehicle Registered")
                            .font(.headline)
                        
                        Text("Please contact support to register your vehicle.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding()
                }
                
                Spacer()
            }
            .padding(.top)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("My Vehicle")
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

struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VehicleView(viewModel: ProfileViewModel())
        }
    }
}
