import Foundation
import Combine

class HabitListViewModel: ObservableObject {
    @Published var habits: [Habit] = [
        Habit(title: "Comprar leche", doneDays: [], dueDate: Date().addingTimeInterval(86400)),
        Habit(title: "Hacer ejercicio", doneDays: [], priority: .high),
        Habit(title: "Llamar a mamá", doneDays: [])
    ]
    
    func addHabit(habit: Habit) {
        habits.append(habit)
    }
    
    func toggleCompletion(habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
        }
    }
}
