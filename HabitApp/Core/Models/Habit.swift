//
//  Habit.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import Foundation
import SwiftData

//Cambiado de struct a class para poder implementar SwiftDataStorageProvider
@Model
class Habit: Identifiable, Codable {
    
    private enum CodingKeys: CodingKey {
        case id, title, isCompleted, doneDays,dueDate, priority, reminderDate
    }
    
    let id: UUID
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
        
        self.id = UUID()
        self.title = title
        self.doneDays = doneDays
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.reminderDate = reminderDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        doneDays = try container.decode([Day].self, forKey: .doneDays)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        priority = try container.decodeIfPresent(Priority.self, forKey: .priority)
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(doneDays, forKey: .doneDays)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encodeIfPresent(priority, forKey: .priority)
        try container.encodeIfPresent(reminderDate, forKey: .reminderDate)
    }
}


enum Priority: String, Codable {
    case low, medium, high
}
