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
    var reminderDate: Date?
    var scheduledDaysString: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
<<<<<<< HEAD
    @Relationship(deleteRule: .cascade, inverse: \DailyNote.habit)
    var notes: [DailyNote] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Goal.habit)
    var goals: [Goal] = []
    
=======
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

>>>>>>> origin/core
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
        
<<<<<<< HEAD
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
=======
        var dates = doneDates
        dates.removeAll { calendar.isDate($0, inSameDayAs: targetDate) }
        
        doneDatesString = dates.map { String($0.timeIntervalSince1970) }.joined(separator: ",")
        updatedAt = Date()
>>>>>>> origin/core
    }
    
    //  Verificar si está completado para una fecha
    func isCompletedForDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        return doneDates.contains { calendar.isDate($0, inSameDayAs: targetDate) }
    }
<<<<<<< HEAD
    
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
=======
>>>>>>> origin/core
}

// MARK: - Priority Enum (Mantenido para evitar errores de Scope)
enum Priority: String, Codable, CaseIterable {
    case low = "Baja"
    case medium = "Media"
    case high = "Alta"
    
<<<<<<< HEAD
    var localized: String {
        switch self {
        case .low: return NSLocalizedString("priority_low", comment: "")
        case .medium: return NSLocalizedString("priority_medium", comment: "")
        case .high: return NSLocalizedString("priority_high", comment: "")
        }
=======
    var displayName: String {
        self.rawValue
>>>>>>> origin/core
    }
}
