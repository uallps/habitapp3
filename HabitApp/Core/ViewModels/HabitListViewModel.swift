import Foundation
import SwiftData
import Combine 

final class HabitListViewModel: ObservableObject {
    
    func addHabit(title: String, 
                  dueDate: Date? = nil, 
                  priority: Priority? = nil, 
                  reminderDate: Date? = nil, 
                  scheduledDays: [Int] = [],
                  context: ModelContext) {
        let habit = Habit(
            title: title,
            dueDate: dueDate,
            priority: priority,
            reminderDate: reminderDate,
            scheduledDays: scheduledDays
        )
        context.insert(habit)
        
        do {
            try context.save()
            
            // Notificar plugins si hay fecha de recordatorio
            if let reminderDate = reminderDate {
                TaskDataObserverManager.shared.notify(
                    taskId: habit.id,
                    title: habit.title,
                    date: reminderDate
                )
            }
        } catch {
            print("Error saving habit: \(error)")
        }
    }
    
    func updateHabit(_ habit: Habit, context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Error updating habit: \(error)")
        }
    }
    
    func toggleCompletion(habit: Habit, for date: Date = Date()) {
        if habit.isCompletedForDate(date) {
            habit.markAsIncomplete(for: date)
        } else {
            habit.markAsCompleted(for: date)
        }
        
        // Notificar al sistema de plugins
        TaskDataObserverManager.shared.notify(
            taskId: habit.id,
            title: habit.title,
            date: habit.dueDate
        )
    }
    
    func deleteHabit(_ habit: Habit, context: ModelContext) {
        context.delete(habit)
        
        do {
            try context.save()
        } catch {
            print("Error deleting habit: \(error)")
        }
    }
    
    func createSampleHabits(context: ModelContext) {
        let sampleHabits = [
            Habit(title: "Hacer ejercicio", priority: .high, scheduledDays: [2, 4, 6]),
            Habit(title: "Leer 30 minutos", priority: .medium, scheduledDays: [1, 2, 3, 4, 5, 6, 7]),
            Habit(title: "Meditar", priority: .low, scheduledDays: [1, 7])
        ]
        
        for habit in sampleHabits {
            context.insert(habit)
        }
        
        do {
            try context.save()
        } catch {
            print("Error creating sample habits: \(error)")
        }
    }
    
    func scheduleHabitsNotification(for date: Date, habits: [Habit]) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let dayHabits = habits.filter { $0.scheduledDays.contains(weekday) }
        
        if !dayHabits.isEmpty {
            let habitTitles = dayHabits.map { $0.title }.joined(separator: ", ")
            let notificationDate = calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: date)) ?? date
            
            TaskDataObserverManager.shared.notify(
                taskId: UUID(),
                title: "Hoy tienes \(dayHabits.count) hábito(s): \(habitTitles)",
                date: notificationDate
            )
        }
    }
}
