import Foundation
import SwiftData

@Model
final class Streak {
    var id: UUID
    var currentCount: Int
    var lastUpdate: Date
    
    // Relación con el hábito para que SwiftData sepa qué observar
    @Relationship(inverse: \Habit.id)
    var habitId: UUID?
    
    init(habitId: UUID) {
        self.id = UUID()
        self.habitId = habitId
        self.currentCount = 0
        self.lastUpdate = Date()
    }
}
