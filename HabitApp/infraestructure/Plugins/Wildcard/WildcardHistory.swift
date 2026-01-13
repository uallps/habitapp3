
import Foundation
import SwiftData

/// Modelo persistente que almacena el historial de habitos comodin seleccionados, 
/// se utiliza para que no se repitan habitos

@Model
final class WildcardHistory {
    
    @Attribute(.unique) var id: UUID
    
    var habitTitle: String
    
    var selectedAt: Date
    
    var relatedHabitId: UUID?
    
    init(habitTitle: String, relatedHabitId: UUID? = nil, selectedAt: Date = Date()) {
        self.id = UUID()
        self.habitTitle = habitTitle
        self.relatedHabitId = relatedHabitId
        self.selectedAt = selectedAt
    }
}
