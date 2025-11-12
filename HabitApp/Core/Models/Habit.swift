//
//  Habit.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import Foundation

struct Habit: Identifiable, Hashable{
    let id = UUID()
    var title: String
    var doneDays: [Day]
    var isCompleted: Bool = false
    var dueDate: Date?
    var reminderDate: Date?
    var activeCategories: CategorySet?
    var scheduledDays: [Int] = [] // 1 = Domingo, 2 = Lunes, ..., 7 = Sábado

    init(title: String,
         doneDays: [Day] = [],
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         priority: Priority? = nil,
         reminderDate: Date? = nil,
         activeCategories: CategorySet? = nil
    ) {
         scheduledDays: [Int] = []) {
        self.title = title
        self.doneDays = doneDays
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.reminderDate = reminderDate
        self.activeCategories = activeCategories
        self.scheduledDays = scheduledDays

    }
}

