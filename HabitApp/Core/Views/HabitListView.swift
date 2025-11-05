//
//  HabitListView.swift
//  HabitApp
//
//  Created by Aula03 on 5/11/25.
//



import SwiftUI

struct HabitListView: View {
    @StateObject var viewModel = HabitListViewModel()

    var body: some View {
        NavigationStack {
            List($viewModel.habits) { $habit in
                NavigationLink(destination: TaskDetailView(habit: $habit)) {
                    TaskRowView(
                        habit: habit,
                        toggleCompletion: {
                            viewModel.toggleCompletion(habit: habit)
                        }
                    )
                }
            }
            .toolbar {
                Button("Añadir Hábito") {
                    let newHabit = Habit(title: "Nuevo Hábito", doneDays: [])
                    viewModel.addHabit(habit: newHabit)
                }
            }
            .navigationTitle("Hábitos")
        }
    }
}
