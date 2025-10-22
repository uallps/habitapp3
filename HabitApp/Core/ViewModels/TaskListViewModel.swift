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
    
}
