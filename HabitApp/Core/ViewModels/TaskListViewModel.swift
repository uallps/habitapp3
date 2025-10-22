//
//  TaskListViewModel.swift
//  TaskApp
//
//  Created by Francisco José García García on 15/10/25.
//
import Foundation
import Combine

class TaskListViewModel: ObservableObject {
    @Published var habits: [Habit] = [
        Habit(title: "Comprar leche", completedDays : [], dueDate: Date().addingTimeInterval(86400)),
        Habit(title: "Hacer ejercicio", completedDays : [], priority: .high),
        Habit(title: "Llamar a mamá", completedDays : [])
    ]
    
    func addHabit(habit : Habit) {
        habits.append(habit)
    }
    
    func toggleCompletion(habit : Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            //habits[index].isCompleted.toggle()
        }
    }
}
