//
//  Habit.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import Foundation
import SwiftData

@Model
class Habit {
    @Attribute(.unique) var id: UUID
    var title: String
    var doneDates: [Date]
    var isCompleted: Bool
    var dueDate: Date?
    var priority: Priority?
    var reminderDate: Date?
    var scheduledDays: [Int] // 1 = Domingo, 2 = Lunes, ..., 7 = Sábado
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \DailyNote.habit)
    var notes: [DailyNote] = []

    init(title: String,
         doneDates: [Date] = [],
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         priority: Priority? = nil,
         reminderDate: Date? = nil,
         scheduledDays: [Int] = []) {
        self.id = UUID()
        self.title = title
        self.doneDates = doneDates
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.reminderDate = reminderDate
        self.scheduledDays = scheduledDays
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func markAsCompleted(for date: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        if !doneDates.contains(where: { calendar.isDate($0, inSameDayAs: today) }) {
            doneDates.append(today)
            updatedAt = Date()
        }
    }
    
    func markAsIncomplete(for date: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        doneDates.removeAll { calendar.isDate($0, inSameDayAs: today) }
        updatedAt = Date()
    }
    
    func isCompletedForDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        return doneDates.contains { calendar.isDate($0, inSameDayAs: targetDate) }
    }
}

enum Priority: String, Codable, CaseIterable {
    case low, medium, high
    
    
    var localized: String {
        switch self {
        case .low: return NSLocalizedString("priority_low", comment: "")
        case .medium: return NSLocalizedString("priority_medium", comment: "")
        case .high: return NSLocalizedString("priority_high", comment: "")
        }
    }
}
