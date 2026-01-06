import Foundation
import SwiftData

@Model
class Habit: Encodable, Decodable, IdentifiableModel {
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
    
    enum CodingKeys: String, CodingKey {
        case id, title, doneDates, isCompleted, dueDate, priority, reminderDate, scheduledDays, createdAt, updatedAt
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
        self.doneDates = doneDates
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.reminderDate = reminderDate
        self.scheduledDays = scheduledDays
        self.priority = priority
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

