import SwiftUI
import Foundation
import Observation

@Observable
class StreakViewModel {
    // Ahora es un simple contenedor. La vista le pasará los datos.
    var currentStreak: Int = 0
    
    // Si necesitas lógica de formato o colores, iría aquí
    var streakColor: Color {
        currentStreak > 5 ? .red : .orange
    }
}
