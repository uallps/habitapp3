//
//  TaskListView.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//


import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel = TaskListViewModel()

    var body: some View {
        VStack {
            Text("Tasks")
                .font(.largeTitle)
                .bold()
                .padding()

            List {
                ForEach($viewModel.tasks) { $task in
                    TaskRowView(task: $task)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview {
    TaskListView()
}

