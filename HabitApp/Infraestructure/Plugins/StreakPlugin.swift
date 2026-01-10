import Foundation
import SwiftData

final class StreakPlugin: HabitDataObservingPlugin {
    var models: [any PersistentModel.Type]
    
    var isEnabled: Bool
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableStreaks
        self.models = [Habit.self]
    }
    
    private let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
     
        // 1. Buscar el hábito para obtener sus doneDates
        Task {
            do {
                guard let habit = try await storageProvider.getHabit(id: taskId) else {
                    return
                }
                
                
                // 2. Calcular la racha con las fechas del hábito
                let streakValue = calculateStreak(from: habit.doneDates)
                
                // 3. Buscar si ya existe un objeto Streak para este hábito
                let predicate = #Predicate<Streak> { $0.habitId == taskId }
                let descriptor = FetchDescriptor<Streak>(predicate: predicate)
                
                let existingStreaks = try context.fetch(descriptor)
                
                if let streakObj = existingStreaks.first {
                    streakObj.currentCount = streakValue
                    streakObj.lastUpdate = Date()
                } else {
                    let newStreak = Streak(habitId: taskId)
                    newStreak.currentCount = streakValue
                    context.insert(newStreak)
                }
                
                // 4. Guardar cambios y procesar para que la UI se entere YA
                try context.save()
                context.processPendingChanges()
                
            } catch {
            }        }

    }
    
    private func calculateStreak(from dates: [Date]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Normalizar a inicio del día y quitar duplicados, ordenadas de más reciente a más antigua
        let sortedDates = Array(Set(dates.map { calendar.startOfDay(for: $0) }))
            .sorted(by: >)
        
        guard let latest = sortedDates.first else { return 0 }
        
        // Si la última vez que se hizo no fue hoy ni ayer, racha rota
        let diff = calendar.dateComponents([.day], from: latest, to: today).day ?? 0
        if diff > 1 { return 0 }
        
        var count = 0
        var referenceDate = latest
        
        for date in sortedDates {
            if date == referenceDate {
                count += 1
                referenceDate = calendar.date(byAdding: .day, value: -1, to: referenceDate)!
            } else {
                break
            }
        }
        return count
    }
}
