import Foundation
import SwiftData
import Combine
import UserNotifications

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
    }
    
    func updateHabit(_ habit: Habit) {
        Task {
            do {
                try await storageProvider.saveContext()
                } catch {
                // Error updating habit
            }
        }

    }
    
    func toggleCompletion(habit: Habit, for date: Date = Date()) {
        Task {
            let wasCompleted = habit.isCompletedForDate(date)
            
            if wasCompleted {
                habit.markAsIncomplete(for: date)
            } else {
                habit.markAsCompleted(for: date)
            }
            
            do {
                try await storageProvider.saveContext()
                
                // Notificar a plugins observadores
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    HabitDataObserverManager.shared.notifyDataChanged(
                        taskId: habit.id,
                        title: habit.title,
                        dueDate: habit.dueDate
                    )
                }
                
            } catch {
                print("Error saving habit: \(error)")
            }
        }

    }
    
    func deleteHabit(_ habit: Habit) {
        Task {
            try await storageProvider.deleteHabit(habit: habit)
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
            
            HabitDataObserverManager.shared.notifyDataChanged(
                taskId: UUID(),
                title: "Hoy tienes \(dayHabits.count) hábito(s): \(habitTitles)",
                dueDate: notificationDate
            )
        }
    }
}
