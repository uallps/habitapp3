import Foundation
import SwiftData
import Combine
import UserNotifications

final class HabitListViewModel: ObservableObject {
    let storageProvider: StorageProvider
    private let wildcardProvider: WildcardHabitProvider?
    
    init(storageProvider: StorageProvider, wildcardProvider: WildcardHabitProvider? = nil) {
        self.storageProvider = storageProvider
        self.wildcardProvider = wildcardProvider
        
        // Ejecutar limpieza de hábitos expirados al iniciar
        Task {
            if let context = SwiftDataContext.shared,
               let provider = wildcardProvider {
                try? provider.cleanupExpiredHabits(context: context)
            }
        }
    }
    
    func unlockWildcardHabit() {
        guard let provider = wildcardProvider,
              let context = SwiftDataContext.shared else { return }
        
        do {
            if let newHabit = try provider.getWildcardHabit(context: context) {
                context.insert(newHabit)
                try context.save()
                print("Hábito comodín desbloqueado: \(newHabit.title)")
            } else {
                print("No hay hábitos comodín disponibles para hoy")
            }
        } catch {
            print("Error al desbloquear hábito comodín: \(error)")
        }
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
            // Programar notificaciones si hay recordatorio
            if reminderDate != nil {
                NotificationManager.shared.scheduleNotification(for: habit)
            }
            //  Notificar plugins si hay fecha de recordatorio
            if let reminderDate = reminderDate {
                HabitDataObserverManager.shared.notifyDataChanged(
                    taskId: habit.id,
                    title: habit.title,
                    dueDate: reminderDate)
            }
        }
        
    }
    
    func updateHabit(_ habit: Habit) {
        Task {
            do {
                try await storageProvider.saveContext()
                // Actualizar notificaciones
                NotificationManager.shared.removeHabitNotifications(for: habit)
                if habit.reminderDate != nil {
                    NotificationManager.shared.scheduleNotification(for: habit)
                }
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
            NotificationManager.shared.removeHabitNotifications(for: habit)
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
