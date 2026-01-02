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
        
        if doneDates.contains(where: { calendar.isDate($0, inSameDayAs: today) }) {
            doneDates.removeAll { calendar.isDate($0, inSameDayAs: today) }
            updatedAt = Date()
        }
    }
    
    private func syncStreakPersistence() {
        if streak == nil { streak = Streak() }
        streak?.currentCount = calculateCurrentStreak()
        streak?.bestCount = calculateLongestStreak()
        streak?.lastCompletionDate = doneDates.sorted().last
    }
    
    func isCompletedForDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        return doneDates.contains { calendar.isDate($0, inSameDayAs: targetDate) }
    }
    
    // MARK: - Lógica de cálculo (Fallback)
    private func calculateCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Si hoy no está hecho, miramos desde ayer
        if !isCompletedForDate(today) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
            currentDate = yesterday
        }
        
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
        
        var maxS = 0
        var currentS = 0
        var lastDate: Date?
        
        for date in sortedDates {
            let current = calendar.startOfDay(for: date)
            if let last = lastDate, let nextDay = calendar.date(byAdding: .day, value: 1, to: last), calendar.isDate(nextDay, inSameDayAs: current) {
                currentS += 1
            } else {
                currentS = 1
            }
            maxS = max(maxS, currentS)
            lastDate = current
        }
        return maxS
    }
}

// MARK: - Priority Enum (Mantenido para evitar errores de Scope)
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
