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
                List($viewModel.habits) { $habit in
                    NavigationLink(destination : TaskDetailView(habit: $habit)) {
                        TaskRowView(habit : habit, toggleCompletion:  {
                            viewModel.toggleCompletion(habit: habit)
                        })
                    }
                }.toolbar {
                    Button("Añadir Tarea") {
                        let newHabit = Habit(title : "Nuevo Hábito")
                        viewModel.addHabit(habit : newHabit)
                    }
                }.navigationTitle("Tareas")
            }
            


        }
    }
}

#Preview {
    TaskListView()
}
