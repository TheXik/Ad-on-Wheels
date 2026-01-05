import SwiftUI

struct VehicleView: View {
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
                
                // Info List
                VStack(spacing: 0) {
                    InfoRow(label: "Make", value: "Toyota")
                    Divider()
                    InfoRow(label: "Model", value: "Prius")
                    Divider()
                    InfoRow(label: "Year", value: "2020")
                    Divider()
                    InfoRow(label: "License Plate", value: "BA-123XY")
                    Divider()
                    InfoRow(label: "Color", value: "White")
                }
                .background(Color.white)
                .cornerRadius(15)
                .padding()
                
                // Status Badge
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
            VehicleView()
        }
    }
}
