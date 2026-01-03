import Foundation
import SwiftData

@Model
class Goal {
    @Attribute(.unique) var id: UUID
    var title: String
    var goalDescription: String
    var targetCount: Int
    var currentCount: Int
    var startDate: Date
    var targetDate: Date
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    var habitId: UUID?
    
    @Relationship(deleteRule: .cascade, inverse: \Milestone.goal)
    var milestones: [Milestone] = []
    
    init(title: String, 
         description: String = "",
         targetCount: Int,
         targetDate: Date,
         habitId: UUID? = nil) {
        self.id = UUID()
        self.title = title
        self.goalDescription = description
        self.targetCount = targetCount
        self.currentCount = 0
        self.startDate = Date()
        self.targetDate = targetDate
        self.isCompleted = false
        self.habitId = habitId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var progress: Double {
        guard targetCount > 0 else { return 0 }
        return min(Double(currentCount) / Double(targetCount), 1.0)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
        return max(days, 0)
    }
    
    func updateProgress(count: Int) {
        currentCount = count
        if currentCount >= targetCount {
            isCompleted = true
        }
        updatedAt = Date()
    }
}