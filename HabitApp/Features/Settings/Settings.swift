import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appConfig: AppConfig

    var body: some View {
        Form {
            Section(header: Text("Features")) {

            }
            
            Section(header: Text("General")) {

            }
        }
        .navigationTitle("Settings")
    }
}
