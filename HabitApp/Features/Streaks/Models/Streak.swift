import Foundation
import SwiftData

@Model
final class Streak {
    var id: UUID
    var currentCount: Int
    var lastUpdate: Date
    var habitId: UUID  // Cambiado a no opcional para mejor compatibilidad con @Query
    
    init(habitId: UUID) {
        self.id = UUID()
        self.habitId = habitId
        self.currentCount = 0
        self.lastUpdate = Date()
    }
}
