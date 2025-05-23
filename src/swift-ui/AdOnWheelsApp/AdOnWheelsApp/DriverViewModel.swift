import Foundation
import Combine

@MainActor
class DriverViewModel: ObservableObject {
    @Published var drivers: [Driver] = []
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var errorMessage: String?

    private let baseURL = "http://localhost:8081/drivers"

    func fetchDrivers() async {
        guard let url = URL(string: baseURL) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([Driver].self, from: data)
            drivers = decoded
        } catch {
            errorMessage = "Failed to fetch drivers: \(error.localizedDescription)"
        }
    }

    func addDriver() async {
        guard !name.isEmpty, !email.isEmpty else {
            errorMessage = "Name and email required"
            return
        }
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let newDriver = Driver(id: nil, name: name, email: email)
        request.httpBody = try? JSONEncoder().encode(newDriver)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let created = try JSONDecoder().decode(Driver.self, from: data)
            drivers.append(created)
            name = ""
            email = ""
        } catch {
            errorMessage = "Failed to add driver: \(error.localizedDescription)"
        }
    }

    func deleteDriver(at offsets: IndexSet) async {
        for index in offsets {
            guard let id = drivers[index].id,
                  let url = URL(string: "\(baseURL)/\(id)") else { continue }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            do {
                _ = try await URLSession.shared.data(for: request)
                drivers.remove(at: index)
            } catch {
                errorMessage = "Failed to delete driver: \(error.localizedDescription)"
            }
        }
    }
} 