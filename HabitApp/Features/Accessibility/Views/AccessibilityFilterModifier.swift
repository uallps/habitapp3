import SwiftUI

struct AccessibilityFilterModifier: ViewModifier {
    @ObservedObject var prefs: UserPreferences

    func body(content: Content) -> some View {
        content
            // 1. Aplicar filtro de daltonismo (Ejemplo simplificado usando saturación/hue)
            .hueRotation(Angle(degrees: daltonismRotation))
            .grayscale(prefs.daltonismType != 0 ? 0.2 : 0)
            
            // 2. Aplicar Modo Noche (Capa naranja semitransparente)
            .overlay(
                Color.orange
                    .opacity(prefs.nightModeIntensity * 0.3) // Máximo 30% de naranja
                    .allowsHitTesting(false) // Permite tocar los botones de debajo
            )
    }

    private var daltonismRotation: Double {
        switch prefs.daltonismType {
            case 1: return 90  // Ajuste cromático para Protanopía
            case 2: return 180 // Ajuste para Deuteranopía
            default: return 0
        }
    }
}
