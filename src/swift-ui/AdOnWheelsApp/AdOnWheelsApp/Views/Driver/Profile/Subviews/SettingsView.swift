import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        List {
            Section(header: Text("Appearance")) {
                Toggle(isOn: $isDarkMode) {
                    HStack {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(isDarkMode ? .purple : .orange)
                        Text("Dark Mode")
                    }
                }
            }
            
            Section(header: Text("App Info")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0 (Mock)")
                        .foregroundColor(.gray)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Settings")
        // Note: Real theming would be applied at root level using .preferredColorScheme
        // For this mock page, we just toggle the state.
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
