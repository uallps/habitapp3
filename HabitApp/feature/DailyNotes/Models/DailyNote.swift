import Foundation
import SwiftData

@Model
class DailyNote {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var date: Date
    var createdAt: Date
    var updatedAt: Date
    
    var habit: Habit?
    
    init(title: String, content: String, date: Date = Date(), habit: Habit? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.date = date
        self.habit = habit
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateContent(title: String, content: String) {
        self.title = title
        self.content = content
        self.updatedAt = Date()
    }
}
