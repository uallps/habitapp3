//
//  HabitRowView.swift
//  HabitApp
//
//  Created by Aula03 on 5/11/25.
//

import SwiftUI

struct HabitRowView: View {
    
    let habit: Habit
    let toggleCompletion: () -> Void
    var date: Date = Date()
    
    var body: some View {
        HStack {
            //  Un solo botón con un solo ícono dinámico
            Button(action: toggleCompletion) {
                Image(systemName: habit.isCompletedForDate(date) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompletedForDate(date) ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                Text(habit.title)
                    .strikethrough(habit.isCompletedForDate(date))
                    .foregroundColor(habit.isCompletedForDate(date) ? .gray : .primary)
                
                if AppConfig.showDueDates, let dueDate = habit.dueDate {
                    Text("Vence: \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if AppConfig.showPriorities, let priority = habit.priority {
                    Text("Prioridad: \(priority.rawValue.capitalized)")
                        .font(.caption)
                        .foregroundColor(priorityColor(for: priority))
                }
            }
            
            Spacer()
            
            NavigationLink {
                HabitNotesView(habit: habit)
            } label: {
                Image(systemName: "note.text")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .buttonStyle(.plain)
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
