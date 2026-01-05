import Foundation
import SwiftData

final class StreakPlugin: TaskDataObservingPlugin {
    private let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    @MainActor
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?, doneDates: [Date]?) {
        guard let dates = doneDates else { return }
        
        let calculatedCount = calcularRacha(con: dates)
        let context = storageProvider.context
        
        // Buscamos si ya existe una racha para este hábito
        let streakPredicate = #Predicate<Streak> { $0.habit?.id == taskId }
        let descriptor = FetchDescriptor<Streak>(predicate: streakPredicate)
        
        do {
            if let existingStreak = try context.fetch(descriptor).first {
                existingStreak.currentCount = calculatedCount
                if calculatedCount > existingStreak.bestCount {
                    existingStreak.bestCount = calculatedCount
                }
                existingStreak.lastUpdate = Date()
                print("🔥 Racha actualizada a: \(calculatedCount)")
            } else if calculatedCount > 0 {
                // Si no existe, buscamos el hábito una sola vez para crear la racha
                let habitPredicate = #Predicate<Habit> { $0.id == taskId }
                if let habit = try context.fetch(FetchDescriptor<Habit>(predicate: habitPredicate)).first {
                    let newStreak = Streak(habit : habit)
                    newStreak.id = UUID()
                    newStreak.currentCount = calculatedCount
                    newStreak.bestCount = calculatedCount
                    newStreak.habit = habit
                    context.insert(newStreak)
                    print("🆕 Racha iniciada: \(calculatedCount)")
                }
            }
            try context.save()
        } catch {
            print("❌ Error en StreakPlugin: \(error)")
        }
    }
    
    private func calcularRacha(con dates: [Date]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sortedDates = dates.map { calendar.startOfDay(for: $0) }.sorted(by: >)
        
        guard let latest = sortedDates.first else { return 0 }
        
        let diff = calendar.dateComponents([.day], from: latest, to: today).day ?? 0
        if diff > 1 { return 0 }
        
        var count = 0
        var reference = latest
        for date in sortedDates {
            if date == reference {
                count += 1
                reference = calendar.date(byAdding: .day, value: -1, to: reference)!
            } else if date < reference { break }
        }
        return count
    }
}
