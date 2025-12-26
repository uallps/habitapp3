import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appConfig: AppConfig

    var body: some View {
        Form {
            Section(header: Text("Features")) {
                // Vistas de configuración proporcionadas por los plugins
                ForEach(Array(PluginRegistry.shared.getPluginSettingsViews().enumerated()), id: \.offset) { _, view in
                    view
                }
            }
            
            Section(header: Text("General")) {
                Toggle("Show Priorities", isOn: $appConfig.showPriorities)
#if PREMIUM
                Toggle("Enable Reminders", isOn: $appConfig.enableReminders)
#endif
                Picker("Storage Type", selection: $appConfig.storageType) {
                    ForEach(StorageType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}
