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
        } catch {
            print("Error saving habit: \(error)")
        }
    }
    
    func toggleCompletion(habit: Habit, for date: Date = Date()) {
        if habit.isCompletedForDate(date) {
            habit.markAsIncomplete(for: date)
        } else {
            habit.markAsCompleted(for: date)
        }
    }
    
    func deleteHabit(_ habit: Habit, context: ModelContext) {
        context.delete(habit)
        
        do {
            try context.save()
        } catch {
            print("Error deleting habit: \(error)")
        }
    }
}
