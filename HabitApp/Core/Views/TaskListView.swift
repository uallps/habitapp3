//
//  TaskListView.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import Foundation

import SwiftUI

struct TaskListView: View {
    @StateObject var viewModel = TaskListViewModel()

    var body: some View {
        VStack{
            List(viewModel.tasks) { task in
                TaskRowView(task: task, toggleCompletion: {
                    viewModel.toggleCompletion(task:task)
                })
            }
            .toolbar {
                Button("Añadir Tarea") {
                    viewModel.addTask("nuevo")
                }
            }.navigationTitle("Tareas")
        }
    }
}

#Preview {
    TaskListView()
}

