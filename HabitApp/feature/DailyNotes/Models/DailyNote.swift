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
    
    init(title: String, content: String, date: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.date = date
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateContent(title: String, content: String) {
        self.title = title
        self.content = content
        self.updatedAt = Date()
    }
}