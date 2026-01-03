import Foundation
import SwiftData

class SwiftDataGoalStorageProvider: GoalStorageProvider {
    
    private let context: ModelContext
    
    init() {
        guard let sharedContext = SwiftDataContext.shared else {
            fatalError("SwiftDataContext not initialized")
        }
        self.context = sharedContext
    }
    
    func loadGoals() async throws -> [Goal] {
        let descriptor = FetchDescriptor<Goal>()
        return try context.fetch(descriptor)
    }
    
    func saveGoals(goals: [Goal]) async throws {
        let existingGoals = try await loadGoals()
        let existingIds = Set(existingGoals.map { $0.id })
        let newIds = Set(goals.map { $0.id })
        
        for existingGoal in existingGoals where !newIds.contains(existingGoal.id) {
            context.delete(existingGoal)
        }
        
        for goal in goals {
            if !existingIds.contains(goal.id) {
                context.insert(goal)
            }
        }
        
        try context.save()
    }
    
    func loadGoalsForHabit(habitId: UUID) async throws -> [Goal] {
        let descriptor = FetchDescriptor<Goal>(
            predicate: #Predicate<Goal> { goal in
                goal.habitId == habitId
            }
        )
        return try context.fetch(descriptor)
    }
}