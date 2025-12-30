import Foundation
import SwiftData

@Model
class Streak {
    @Attribute(.unique) var id: UUID
    var currentCount: Int
    var bestCount: Int
    var lastCompletionDate: Date?
    
    // Relación con el Hábito (opcional para que SwiftData gestione la integridad)
    var habit: Habit?

    init(currentCount: Int = 0, bestCount: Int = 0, lastCompletionDate: Date? = nil) {
        self.id = UUID()
        self.currentCount = currentCount
        self.bestCount = bestCount
        self.lastCompletionDate = lastCompletionDate
    }

    /// Lógica interna para actualizar la racha
    func update(completionDate: Date) {
        let calendar = Calendar.current
        
        guard let lastDate = lastCompletionDate else {
            // Primera vez que se completa
            currentCount = 1
            lastCompletionDate = completionDate
            bestCount = max(bestCount, currentCount)
            return
        }

        // Si ya se completó hoy, no hacemos nada
        if calendar.isDate(lastDate, inSameDayAs: completionDate) { return }

        // Comprobamos si es exactamente el día siguiente
        let yesterday = calendar.date(byAdding: .day, value: -1, to: completionDate)!
        
        if calendar.isDate(lastDate, inSameDayAs: yesterday) {
            currentCount += 1
        } else {
            // Se rompió la racha
            currentCount = 1
        }
        
        lastCompletionDate = completionDate
        bestCount = max(bestCount, currentCount)
    }
}
