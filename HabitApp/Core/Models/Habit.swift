//
//  Habit.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import Foundation

struct Habit: Identifiable {
    let id = UUID()
    var title: String
    var doneDays: [Day]
    var isCompleted: Bool = false
    var dueDate: Date?
    var priority: Priority?
    var reminderDate: Date?

    init(title: String,
         doneDays: [Day] = [],
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         priority: Priority? = nil,
         reminderDate: Date? = nil) {
        self.title = title
        self.doneDays = doneDays
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.reminderDate = reminderDate
    }
}

enum Priority: String, Codable {
    case low, medium, high
}

