import SwiftUI

struct DriverListView: View {
    @StateObject private var viewModel = DriverViewModel()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Name", text: $viewModel.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        Task { await viewModel.addDriver() }
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.email.isEmpty)
                }
                .padding()

                Button("Refresh Drivers") {
                    Task { await viewModel.fetchDrivers() }
                }
                .padding(.bottom)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                List {
                    ForEach(viewModel.drivers) { driver in
                        VStack(alignment: .leading) {
                            Text(driver.name).font(.headline)
                            Text(driver.email).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                    .onDelete { offsets in
                        Task { await viewModel.deleteDriver(at: offsets) }
                    }
                }
            }
            .navigationTitle("Drivers")
        }
        .task { await viewModel.fetchDrivers() }
    }
} 