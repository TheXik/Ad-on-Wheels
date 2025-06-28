import SwiftUI

struct MainView: View {
    @State private var role: UserRole = .driver
    @State private var driverIdInput: String = ""
    @State private var selectedDriverIndex: Int? = nil
    @State private var selectedCompanyIndex: Int? = nil
    @StateObject private var driverViewModel = DriverViewModel()
    @StateObject private var companyViewModel = CompanyViewModel()
    @State private var drivers: [Driver] = []
    @State private var companies: [Company] = []

    var body: some View {
        NavigationView {
            VStack {
                Picker("Role", selection: $role) {
                    ForEach(UserRole.allCases, id: \ .self) { role in
                        Text(role.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: role) { oldValue, newValue in
                    if newValue == .driver {
                        fetchDrivers()
                        driverViewModel.driverId = nil
                        selectedDriverIndex = nil
                    } else {
                        fetchCompanies()
                        companyViewModel.selectedCompanyId = nil
                        selectedCompanyIndex = nil
                    }
                }
                .onAppear {
                    if role == .driver {
                        fetchDrivers()
                    } else {
                        fetchCompanies()
                    }
                }

                if role == .driver {
                    if driverViewModel.driverId == nil {
                        VStack(spacing: 12) {
                            Text("Login as Driver")
                                .font(.headline)
                            if drivers.isEmpty {
                                ProgressView("Loading drivers...")
                            } else {
                                Picker("Select Driver", selection: $selectedDriverIndex) {
                                    ForEach(Array(drivers.enumerated()), id: \ .element.id) { idx, driver in
                                        Text("\(driver.name) (ID: \(driver.id))").tag(Optional(idx))
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(maxWidth: 300)
                                Button("Login") {
                                    if let idx = selectedDriverIndex {
                                        let driver = drivers[idx]
                                        driverViewModel.driverId = driver.id
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(selectedDriverIndex == nil)
                            }
                        }
                        .padding()
                    } else {
                        DriverView(viewModel: driverViewModel)
                    }
                } else {
                    if companyViewModel.selectedCompanyId == nil {
                        VStack(spacing: 12) {
                            Text("Login as Company")
                                .font(.headline)
                            if companies.isEmpty {
                                ProgressView("Loading companies...")
                            } else {
                                Picker("Select Company", selection: $selectedCompanyIndex) {
                                    ForEach(Array(companies.enumerated()), id: \ .element.id) { idx, company in
                                        Text("\(company.name) (ID: \(company.id))").tag(Optional(idx))
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(maxWidth: 300)
                                Button("Login") {
                                    if let idx = selectedCompanyIndex {
                                        let company = companies[idx]
                                        companyViewModel.selectedCompanyId = company.id
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(selectedCompanyIndex == nil)
                            }
                        }
                        .padding()
                    } else {
                        CompanyView(viewModel: companyViewModel)
                    }
                }
            }
            .navigationTitle("Ad-on-Wheels")
        }
    }

    private func fetchDrivers() {
        guard let url = URL(string: "http://localhost:8081/drivers") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let fetchedDrivers = try JSONDecoder().decode([Driver].self, from: data)
                drivers = fetchedDrivers
            } catch {
                print("Error fetching drivers: \(error)")
            }
        }
    }

    private func fetchCompanies() {
        guard let url = URL(string: "http://localhost:8083/companies") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let fetchedCompanies = try JSONDecoder().decode([Company].self, from: data)
                companies = fetchedCompanies
            } catch {
                print("Error fetching companies: \(error)")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
} 