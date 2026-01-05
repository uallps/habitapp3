import Foundation
import SwiftData
import Combine

@MainActor
final class HabitListViewModel: ObservableObject {
    private let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    func addHabit(title: String, dueDate: Date? = nil, priority: Priority? = nil, reminderDate: Date? = nil, scheduledDays: [Int] = []) {
        let habit = Habit(title: title, dueDate: dueDate, priority: priority, reminderDate: reminderDate, scheduledDays: scheduledDays)
        storageProvider.context.insert(habit)
        saveAndNotify(habit: habit)
    }

    func updateHabit(_ habit: Habit) {
        saveAndNotify(habit: habit)
    }
    
    func toggleCompletion(habit: Habit, for date: Date = Date()) {
        if habit.isCompletedForDate(date) {
            habit.markAsIncomplete(for: date)
        } else {
            habit.markAsCompleted(for: date)
        }
        saveAndNotify(habit: habit)
    }
    
    func deleteHabit(_ habit: Habit) {
        storageProvider.context.delete(habit)
        try? storageProvider.context.save()
    }

    func scheduleHabitsNotification(for date: Date, habits: [Habit]) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let dayHabits = habits.filter { $0.scheduledDays.contains(weekday) }
        
        if !dayHabits.isEmpty {
            let habitTitles = dayHabits.map { $0.title }.joined(separator: ", ")
            let notificationDate = calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: date)) ?? date
            
            PluginRegistry.shared.notifyDataChanged(taskId: UUID(), title: "Hoy: \(habitTitles)", dueDate: notificationDate, doneDates: nil)
        }
    }
    
    private func saveAndNotify(habit: Habit) {
        do {
            try storageProvider.context.save()
            storageProvider.context.processPendingChanges()
            
            print("💾 ViewModel guardó: \(habit.doneDates.count) fechas para '\(habit.title)'")

            // Enviamos las fechas directamente para evitar latencia de SwiftData
            PluginRegistry.shared.notifyDataChanged(
                taskId: habit.id,
                title: habit.title,
                dueDate: habit.dueDate,
                doneDates: habit.doneDates
            )
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
