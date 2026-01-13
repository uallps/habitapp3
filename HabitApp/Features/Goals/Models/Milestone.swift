import Foundation
import SwiftData

@Model
class Milestone {
    @Attribute(.unique) var id: UUID
    var title: String
    var targetValue: Int
    var isCompleted: Bool
    var completedDate: Date?
    var createdAt: Date
    
    var goal: Goal?
    
    init(title: String, targetValue: Int, goal: Goal? = nil) {
        self.id = UUID()
        self.title = title
        self.targetValue = targetValue
        self.isCompleted = false
        self.goal = goal
        self.createdAt = Date()
    }
    
    func complete() {
        isCompleted = true
        completedDate = Date()
    }
}