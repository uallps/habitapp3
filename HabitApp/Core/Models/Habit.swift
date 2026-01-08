import Foundation
import SwiftData

@Model
class Habit: Encodable, Decodable, Hashable {
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

=======
    @Relationship(deleteRule: .cascade, inverse: \DailyNote.habit)
    var notes: [DailyNote] = []
    
    enum CodingKeys: String, CodingKey {
        case id, title, doneDates, isCompleted, dueDate, priority, reminderDate, scheduledDays, createdAt, updatedAt
    }
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(doneDates, forKey: .doneDates)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(priority, forKey: .priority)
        try container.encode(reminderDate, forKey: .reminderDate)
        try container.encode(scheduledDays, forKey: .scheduledDays)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        // Note: `notes` relationship is usually not encoded
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        doneDates = try container.decode([Date].self, forKey: .doneDates)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        priority = try container.decodeIfPresent(Priority.self, forKey: .priority)
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        scheduledDays = try container.decode([Int].self, forKey: .scheduledDays)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        notes = [] // relationship is not decoded here
    }
    
>>>>>>> ismael
    init(title: String,
         doneDates: [Date] = [],
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         priority: Priority? = nil,
         reminderDate: Date? = nil,
         activeCategories: Category? = nil,
         scheduledDays: [Int] = []) {
        self.id = UUID()
        self.title = title
        self.doneDatesString = doneDates.map { String($0.timeIntervalSince1970) }.joined(separator: ",")
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.reminderDate = reminderDate
<<<<<<< HEAD
        self.scheduledDaysString = scheduledDays.map { String($0) }.joined(separator: ",")
=======
        self.scheduledDays = scheduledDays
        self.priority = priority
>>>>>>> ismael
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

<<<<<<< HEAD
enum Priority: String, Codable, CaseIterable {
    case low = "Baja"
    case medium = "Media"
    case high = "Alta"
    
    var displayName: String {
        return self.rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        // Handle both English and Spanish values for backward compatibility
        switch rawValue {
        case "Baja", "low":
            self = .low
        case "Media", "medium":
            self = .medium
        case "Alta", "high":
            self = .high
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot initialize Priority from invalid String value \(rawValue)"
            )
        }
    }
}
=======
>>>>>>> ismael
