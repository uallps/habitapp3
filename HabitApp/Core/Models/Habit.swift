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
    

    
    @Relationship(deleteRule: .cascade, inverse: \Goal.habit)
    var goals: [Goal] = []
    
    // MARK: - Streak Properties
    var currentStreak: Int {
        calculateCurrentStreak()
    }
    
    var longestStreak: Int {
        calculateLongestStreak()
    }
    
    var streakStartDate: Date? {
        guard currentStreak > 0 else { return nil }
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -(currentStreak - 1), to: Date())
    }

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
    
    // MARK: - Streak Calculations
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        while isCompletedForDate(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        let calendar = Calendar.current
        let sortedDates = doneDates.sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let previousDate = calendar.startOfDay(for: sortedDates[i-1])
            let currentDate = calendar.startOfDay(for: sortedDates[i])
            
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDate),
               calendar.isDate(nextDay, inSameDayAs: currentDate) {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return longestStreak
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
