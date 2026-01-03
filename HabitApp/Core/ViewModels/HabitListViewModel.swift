//  HabitListViewModel.swift
//  HabitApp
//
//

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
        storageProvider.context.insert(habit)
        
        do {
            try storageProvider.context.save()
            
            // ⭐ Notificar plugins si hay fecha de recordatorio
            if let reminderDate = reminderDate {
                PluginRegistry.shared.notifyDataChanged(
                    taskId: habit.id,
                    title: habit.title,
                    dueDate: reminderDate
                )
            }
        } catch {
            print("❌ Error saving habit: \(error)")
        }
    }
    
    func updateHabit(_ habit: Habit) {
        do {
            try storageProvider.context.save()
        } catch {
            print("❌ Error updating habit: \(error)")
        }
    }
    
    func toggleCompletion(habit: Habit, for date: Date = Date()) {
        if habit.isCompletedForDate(date) {
            habit.markAsIncomplete(for: date)
        } else {
            habit.markAsCompleted(for: date)
        }
        
        // ⭐ Guardar cambios inmediatamente
        do {
            try storageProvider.context.save()
            print("✅ Hábito '\(habit.title)' guardado - Días completados: \(habit.doneDates.count)")
        } catch {
            print("❌ Error saving habit: \(error)")
            return
        }
        
        // ⭐ Notificar plugins DESPUÉS de guardar
        PluginRegistry.shared.notifyDataChanged(
            taskId: habit.id,
            title: habit.title,
            dueDate: habit.dueDate
        )
    }
    
    func deleteHabit(_ habit: Habit) {
        storageProvider.context.delete(habit)
        
        do {
            try storageProvider.context.save()
        } catch {
            print("❌ Error deleting habit: \(error)")
        }
    }
    
    func createSampleHabits() {
        let sampleHabits = [
            Habit(title: "Hacer ejercicio", priority: .high, scheduledDays: [2, 4, 6]),
            Habit(title: "Leer 30 minutos", priority: .medium, scheduledDays: [1, 2, 3, 4, 5, 6, 7]),
            Habit(title: "Meditar", priority: .low, scheduledDays: [1, 7])
        ]
        
        for habit in sampleHabits {
            storageProvider.context.insert(habit)
        }
        
        do {
            try storageProvider.context.save()
            print("✅ Hábitos de muestra creados")
        } catch {
            print("❌ Error creating sample habits: \(error)")
        }
    }
    
    func scheduleHabitsNotification(for date: Date, habits: [Habit]) {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let dayHabits = habits.filter { $0.scheduledDays.contains(weekday) }
        
        if !dayHabits.isEmpty {
            let habitTitles = dayHabits.map { $0.title }.joined(separator: ", ")
            let notificationDate = calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: date)) ?? date
            
            PluginRegistry.shared.notifyDataChanged(
                taskId: UUID(),
                title: "Hoy tienes \(dayHabits.count) hábito(s): \(habitTitles)",
                dueDate: notificationDate
            )
        }
    }
}
