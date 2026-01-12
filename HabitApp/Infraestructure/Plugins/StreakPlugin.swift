import Foundation
import SwiftData

final class StreakPlugin: HabitDataObservingPlugin {
    var models: [any PersistentModel.Type]
    
    var isEnabled: Bool
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableStreaks
        self.models = [Streak.self]
        self.storageProvider = config.storageProvider
    }
    
    private let storageProvider: StorageProvider
        
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        print("🔥 StreakPlugin.onDataChanged called - habit: \(title), id: \(taskId)")
        
        // 1. Buscar el hábito para obtener sus doneDates
        Task {
            do {
                let habit : Habit? = try await storageProvider.getHabit(id: taskId)
                if habit == nil { 
                    print("⚠️ Habit not found")
                    return
                }
                
                print("📅 Habit '\(habit!.title)' has \(habit!.doneDates.count) completed dates")
                
                // 2. Calcular la racha con las fechas del hábito
                let streakValue = calculateStreak(from: habit!.doneDates)
                print("🔥 Calculated streak: \(streakValue)")
                
                let existingStreaks = try await storageProvider.loadStreaksForHabit(habitId: taskId)
                print("🔍 Found \(existingStreaks.count) existing streaks")
                
                if let streakObj = existingStreaks.first {
                    streakObj.currentCount = streakValue
                    streakObj.lastUpdate = Date()
                    try await storageProvider.updateStreak(streakObj)
                    print("✅ Updated existing streak")
                } else {
                    let newStreak = Streak(habitId: taskId)
                    newStreak.currentCount = streakValue
                    newStreak.habitId = taskId
                    try await storageProvider.saveStreak(newStreak)
                    print("✨ Created new streak")
                }
                
            } catch {
                print("❌ Error in StreakPlugin: \(error)")
            }        
        }
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
