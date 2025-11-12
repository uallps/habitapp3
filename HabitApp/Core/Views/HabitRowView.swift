//
//  TaskListRowView.swift
//  TaskApp
//
//  Created by Francisco José García García on 15/10/25.
//

import SwiftUI

struct HabitRowView: View {
    
    let habit: Habit
    let toggleCompletion : () -> Void
    
    @EnvironmentObject private var AppConfig: AppConfig
    
    
    var body: some View {
        HStack {
            Button(action: toggleCompletion){
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
            }.buttonStyle(.plain)
            VStack(alignment: .leading) {
                Text(habit.title)
                    .strikethrough(habit.isCompleted)
                if AppConfig.showDueDates, let dueDate = habit.dueDate {
                    Text("Vence: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if AppConfig.showPriorities, let priority = habit.priority {
                    Text("Prioridad: \(priority.rawValue)")
                        .font(.caption)
                        .foregroundColor(priorityColor(for: priority))
                }
                if AppConfig.enableReminders, let reminderDate = habit.reminderDate{
                    Label("Recordatorio: \(reminderDate.formatted(date: .abbreviated, time: .shortened))", systemImage: "bell")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func priorityColor(for priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
}
