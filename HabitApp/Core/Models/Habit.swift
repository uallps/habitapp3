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
    var doneDatesString: String
    var isCompleted: Bool
    var dueDate: Date?
    var priority: Priority?
    var reminderDate: Date?
    var scheduledDaysString: String
    var createdAt: Date
    var updatedAt: Date
    
    var doneDates: [Date] {
        get {
            doneDatesString.split(separator: ",").compactMap { 
                Double($0).map { Date(timeIntervalSince1970: $0) }
            }
        }
        set {
            doneDatesString = newValue.map { String($0.timeIntervalSince1970) }.joined(separator: ",")
        }
    }
    
    var scheduledDays: [Int] {
        get {
            scheduledDaysString.split(separator: ",").compactMap { Int($0) }
        }
        set {
            scheduledDaysString = newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
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
        self.doneDatesString = doneDates.map { String($0.timeIntervalSince1970) }.joined(separator: ",")
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.reminderDate = reminderDate
        self.scheduledDaysString = scheduledDays.map { String($0) }.joined(separator: ",")
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func markAsCompleted(for date: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        var dates = doneDates
        if !dates.contains(where: { calendar.isDate($0, inSameDayAs: today) }) {
            dates.append(today)
            doneDates = dates
            updatedAt = Date()
        }
    }
    
    func markAsIncomplete(for date: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        var dates = doneDates
        dates.removeAll { calendar.isDate($0, inSameDayAs: today) }
        doneDates = dates
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
}
