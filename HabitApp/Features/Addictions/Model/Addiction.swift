import Foundation
import SwiftData

@Model
class Addiction {
    
    @Attribute(.unique) var id: UUID = UUID()
    
    // Describe la gravedad de la adicción
    var severity: AddictionSeverity
    
    var title: String
    
    // Un triggers son hábitos que pueden provocar la recaída, pues son situaciones, emociones o entornos que aumentan el deseo de consumir la sustancia o realizar el comportamiento adictivo.
    // Deben ser por tanto, evitados o gestionados cuidadosamente.
    var triggers: [Habit]
    
    // Hábitos para evitar la adicción
    var preventionHabits: [Habit]
    // Hábitos para aliviar los efectos negativos en caso de recaída
    var compensatoryHabits: [Habit]
    
    // Número de veces que el usuario ha recaído en la adicción
    var relapseCount: Int = 0

    
    init(title: String,
         severity: AddictionSeverity = .medium,
         triggers: [Habit] = [],
         preventionHabits: [Habit] = [],
         compensatoryHabits: [Habit] = []) {
        
        self.severity = severity
        self.triggers = triggers
        self.preventionHabits = preventionHabits
        self.compensatoryHabits = compensatoryHabits
        self.title = title
    }

    enum AddictionSeverity: String, Codable, CaseIterable, Hashable {
        case low, medium, high

        var emoji: String {
            switch self {
            case .high: return "🚬"
            case .medium: return "📱"
            case .low: return "☕️"
            }
        }

        var displayName: String {
            switch self {
            case .low: return "Baja"
            case .medium: return "Media"
            case .high: return "Alta"
            }
        }
    }
}
