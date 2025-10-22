//
//  TaskState.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//
import Foundation
import Combine
class TaskListViewModel : ObservableObject{
    @Published var tasks : [Task] = [
        Task(title: "Comprar leche", dueDate: Date().addingTimeInterval(86400)),
        Task(title: "Hacer ejercicio",priority: .high),
        Task(title: "Llamar a mamá")
    ]
    
    func addTask(_ title: String) {
        tasks.append(Task(title: title))
    }

    func toggleCompletion(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    }


