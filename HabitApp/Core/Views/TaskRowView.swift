//
//  TaskRowView.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//


import SwiftUI

struct TaskRowView: View {
    @Binding var task: Task
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .font(.headline)
                
                if AppConfig.showDueDates, let dueDate = task.dueDate {
                    Text("Due: \(dueDate, formatter: dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if AppConfig.showPriorities, let priority = task.priority {
                    Text("Priority: \(priority.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(color(for: priority))
                }
            }
            Spacer()
            Button(action: {
                task.isCompleted.toggle()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .imageScale(.large)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
    }
    
    func color(for priority: Priority) -> Color {
        switch priority {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

