import SwiftUI
import SwiftData

final class AccessibilityPlugin: ViewPlugin {
    var models: [any PersistentModel.Type] { [] }
    var isEnabled: Bool = true
    private let config: AppConfig

    init(config: AppConfig) {
        self.config = config
    }

    typealias TaskRowContent = EmptyView
    typealias TaskDetailContent = EmptyView
    typealias SettingsContent = AccessibilitySettingsView

    @ViewBuilder
    func settingsView() -> AccessibilitySettingsView {
        AccessibilitySettingsView(prefs: config.userPreferences)
    }
}

struct AccessibilitySettingsView: View {
    @ObservedObject var prefs: UserPreferences
    
    // 1. Definimos la lista de colores disponibles que faltaba
    let colors = ["Blue", "Red", "Green", "Orange", "Purple", "Pink"]

    var body: some View {
        // 2. Sección de Color de Acento
        Section("Personalización de Color") {
            Picker("Color de acento", selection: $prefs.accentColorName) {
                ForEach(colors, id: \.self) { colorName in
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(colorFromName(colorName))
                        Text(colorName)
                    }
                    .tag(colorName)
                }
            }
            .pickerStyle(.navigationLink)
        }

        // 3. Sección de Accesibilidad
        Section("Accesibilidad") {
            Picker("Filtro Daltonismo", selection: $prefs.daltonismType) {
                Text("Desactivado").tag(0)
                Text("Protanopía").tag(1)
                Text("Deuteranopía").tag(2)
                Text("Tritanopía").tag(3)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Modo Noche (Luz cálida)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Slider(value: $prefs.nightModeIntensity, in: 0...1)
            }
        }
    }
    private func colorFromName(_ name: String) -> Color {
        switch name {
        case "Red": return .red
        case "Green": return .green
        case "Orange": return .orange
        case "Purple": return .purple
        case "Pink": return .pink
        default: return .blue
        }
    }
}
