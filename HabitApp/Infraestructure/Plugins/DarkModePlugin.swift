import SwiftUI
import SwiftData

final class DarkModePlugin: ViewPlugin {
    var models: [any PersistentModel.Type] { [] } // No necesita modelos nuevos
    var isEnabled: Bool = true
    private let config: AppConfig
    
    init(config: AppConfig) {
        self.config = config
    }
    
    // Implementamos los tipos asociados requeridos por ViewPlugin
    typealias RowContent = EmptyView
    typealias DetailContent = EmptyView
    typealias SettingsContent = DarkModeSettingsView

    @ViewBuilder
    func settingsView() -> DarkModeSettingsView {
        DarkModeSettingsView(userPreferences: config.userPreferences)
    }
}

// Vista específica para los ajustes del modo oscuro
struct DarkModeSettingsView: View {
    @ObservedObject var userPreferences: UserPreferences
    
    var body: some View {
        Section("Apariencia") {
            Picker("Tema del dispositivo", selection: $userPreferences.appTheme) {
                Text("Sistema").tag(0)
                Text("Claro").tag(1)
                Text("Oscuro").tag(2)
            }
            .pickerStyle(.segmented)
        }
    }
}
