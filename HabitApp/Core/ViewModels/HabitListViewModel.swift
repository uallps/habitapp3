import Foundation
import SwiftData
import Combine

final class HabitListViewModel: ObservableObject {
    private let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    func addHabit(title: String,
                  dueDate: Date? = nil,
                  priority: Priority? = nil,
                  reminderDate: Date? = nil,
                  scheduledDays: [Int] = []) {
        let habit = Habit(
            title: title,
            dueDate: dueDate,
            priority: priority,
            reminderDate: reminderDate,
            scheduledDays: scheduledDays
        )
        
        Task {
            try await storageProvider.addHabit(habit: habit)
            //  Notificar plugins si hay fecha de recordatorio
            if let reminderDate = reminderDate {
                TaskDataObserverManager.shared.notifyDataChanged(
                    taskId: habit.id,
                    title: habit.title,
                    dueDate: reminderDate
                )
            }
        }
        
    }
    
    func updateHabit(_ habit: Habit) {
        Task {
            do {
                try await storageProvider.saveContext()
            } catch {
                print(" Error updating habit: \(error)")
            }
        }

    }
    
    func toggleCompletion(habit: Habit, for date: Date = Date()) {
        Task {
            if habit.isCompletedForDate(date) {
                habit.markAsIncomplete(for: date)
            } else {
                habit.markAsCompleted(for: date)
            }
            
            do {
                try await storageProvider.saveContext()
                print(" Hábito '\(habit.title)' guardado - Días completados: \(habit.doneDates.count)")
                
                //  Esperar a que SwiftData sincronice completamente
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    TaskDataObserverManager.shared.notifyDataChanged(
                        taskId: habit.id,
                        title: habit.title,
                        dueDate: habit.dueDate
                    )
                }
            } catch {
                print(" Error saving habit: \(error)")
            }
        }

    }
    
    func deleteHabit(_ habit: Habit) {
        Task {
            try await storageProvider.deleteHabit(habit: habit)
            try await storageProvider.saveContext()
        }
    }
    
    func createSampleHabits() {
        Task {
            let sampleHabits = [
                Habit(title: "Hacer ejercicio", priority: .high, scheduledDays: [1,  3, 4,  6, 7]),
                Habit(title: "Leer 30 minutos", priority: .medium, scheduledDays: [ 2,  4, 5,  7]),
                Habit(title: "Meditar", priority: .low, scheduledDays: [1, 2,  5, 6, 7])
            ]
            
            for habit in sampleHabits {
                try await storageProvider.addHabit(habit: habit)
            }
            
            do {
                try await storageProvider.saveContext()
                print(" Hábitos de muestra creados")
            } catch {
                print(" Error creating sample habits: \(error)")
            }
        }

    }
    
    func scheduleHabitsNotification(for date: Date, habits: [Habit]) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let dayHabits = habits.filter { $0.scheduledDays.contains(weekday) }
        
        if !dayHabits.isEmpty {
            let habitTitles = dayHabits.map { $0.title }.joined(separator: ", ")
            let notificationDate = calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: date)) ?? date
            
            TaskDataObserverManager.shared.notifyDataChanged(
                taskId: UUID(),
                title: "Hoy tienes \(dayHabits.count) hábito(s): \(habitTitles)",
                dueDate: notificationDate
            )
        }
    }
}
