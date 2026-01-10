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
    var doneDatesString: String = ""
    var isCompleted: Bool = false
    var dueDate: Date?
    var priority: Priority? = nil
    var isReminderEnabled: Bool = false
    var reminderDate: Date? = nil
    var scheduledDaysString: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    //  Computed property para obtener las fechas completadas
    var doneDates: [Date] {
        guard !doneDatesString.isEmpty else {
            return []
        }
        
        let dates = doneDatesString.split(separator: ",").compactMap { dateString -> Date? in
            let trimmed = String(dateString).trimmingCharacters(in: .whitespaces)
            
            if let timeInterval = Double(trimmed) {
                return Date(timeIntervalSince1970: timeInterval)
            }
            return nil
        }
        
        return dates
    }
    
    var scheduledDays: [Int] {
        guard !scheduledDaysString.isEmpty else { return [] }
        return scheduledDaysString.split(separator: ",").compactMap { Int($0) }
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
    
    //  Marcar como completado para una fecha
    func markAsCompleted(for date: Date = Date()) {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        // Evitar duplicados
        if !isCompletedForDate(targetDate) {
            let timeString = String(targetDate.timeIntervalSince1970)
            
            if doneDatesString.isEmpty {
                doneDatesString = timeString
            } else {
                doneDatesString += ",\(timeString)"
            }
            isCompleted = true
            updatedAt = Date()
        }
    }
    
    //  Marcar como incompleto
    func markAsIncomplete(for date: Date = Date()) {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        
        var dates = doneDates
        dates.removeAll { calendar.isDate($0, inSameDayAs: targetDate) }
        
        doneDatesString = dates.map { String($0.timeIntervalSince1970) }.joined(separator: ",")
        updatedAt = Date()
    }
    
    //  Verificar si está completado para una fecha
    func isCompletedForDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        return doneDates.contains { calendar.isDate($0, inSameDayAs: targetDate) }
    }
}


