//
//  TaskListView.swift
//  TaskApp
//
//  Created by Francisco José García García on 15/10/25.
//
import Foundation
import SwiftUI

struct TaskListView: View {
    @StateObject var viewModel = TaskListViewModel()

    var body: some View {
        VStack{
            
            NavigationStack {
                List($viewModel.tasks) { $habit in
                    NavigationLink(destination : TaskDetailView(task: $task)) {
                        TaskRowView(habit : habit, toggleCompletion:  {
                            viewModel.toggleCompletion(task: task)
                        })
                    }
                }.toolbar {
                    Button("Añadir Tarea") {
                        let newHabit = Habit(title : "Nueva Tarea")
                        viewModel.addTask(habit : newTask)
                    }
                }.navigationTitle("Tareas")
            }
            


        }
    }
}

#Preview {
    TaskListView()
}
