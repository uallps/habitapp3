import SwiftData
import Foundation

final class StreakPlugin: TaskDataObservingPlugin {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        // 1. Intentamos recuperar el Hábito (Core)
        let habitPredicate = #Predicate<Habit> { $0.id == taskId }
        let habitDescriptor = FetchDescriptor<Habit>(predicate: habitPredicate)
        
        guard let habit = try? context.fetch(habitDescriptor).first else {
            print("⚠️ StreakPlugin: No se encontró el hábito con ID \(taskId)")
            return
        }

        // 2. Buscamos la Racha (Feature) que apunta a este hábito
        // Como la relación es inversa, buscamos el Streak cuyo habit.id coincida
        let streakPredicate = #Predicate<Streak> { $0.habit?.id == taskId }
        let streakDescriptor = FetchDescriptor<Streak>(predicate: streakPredicate)
        
        let streak: Streak
        
        if let existingStreak = try? context.fetch(streakDescriptor).first {
            streak = existingStreak
        } else {
            // 3. Si no existe racha para este hábito, la creamos (Lazy Creation)
            streak = Streak(habit: habit)
            context.insert(streak)
            print("🔥 StreakPlugin: Nueva racha creada para '\(title)'")
        }

        // 4. Ordenamos a la racha que recalcule sus valores basándose en el Core
        streak.update()

        // 5. Persistimos los cambios en la base de datos
        do {
            try context.save()
            print("✅ StreakPlugin: Racha actualizada (Actual: \(streak.currentCount) | Récord: \(streak.bestCount))")
        } catch {
            print("❌ StreakPlugin: Error al guardar cambios: \(error)")
        }
    }
}
