import SwiftData
import Foundation

final class StreakPlugin: TaskDataObservingPlugin {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        // 1. Buscamos el hábito que ha sido modificado
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == taskId })
        guard let habit = try? context.fetch(descriptor).first else { return }

        // 2. Si el hábito no tiene un objeto Streak asignado, lo creamos
        if habit.streak == nil {
            let newStreak = Streak()
            newStreak.habit = habit
            habit.streak = newStreak
            context.insert(newStreak)
        }

        // 3. Obtenemos la última fecha de completado para actualizar la racha
        // Usamos la fecha más reciente de doneDates
        if let lastCompletion = habit.doneDates.sorted().last {
            habit.streak?.update(completionDate: lastCompletion)
        } else {
            // Si no hay fechas, la racha es 0
            habit.streak?.currentCount = 0
        }

        // 4. Persistimos los cambios
        do {
            try context.save()
            print("🔥 StreakPlugin: Racha actualizada para '\(title)' - Actual: \(habit.currentStreak)")
        } catch {
            print("❌ StreakPlugin: Error al guardar racha: \(error)")
        }
    }
}