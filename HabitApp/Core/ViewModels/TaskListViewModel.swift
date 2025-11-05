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
        Habit(title: "Comprar leche", doneDays : [], dueDate: Date().addingTimeInterval(86400)),
        Habit(title: "Hacer ejercicio", doneDays : [], priority: .high),
        Habit(title: "Llamar a mamá", doneDays : [])
    ]
    
    func addHabit(habit : Habit) {
        habits.append(habit)
    }
    
    func toggleCompletion(habit : Habit) {
        if habits.firstIndex(where: { $0.id == habit.id }) != nil {
            //habits[index].isCompleted.toggle()
        }
    }
}
