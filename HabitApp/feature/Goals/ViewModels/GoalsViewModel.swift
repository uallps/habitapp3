import Foundation
import SwiftData
import Combine

final class GoalsViewModel: ObservableObject {
    
    @Published var goals: [Goal] = []
    
    func getActiveGoals(_ goals: [Goal]) -> [Goal] {
        return goals.filter { !$0.isCompleted }.sorted { $0.targetDate < $1.targetDate }
    }
    
    func getCompletedGoals(_ goals: [Goal]) -> [Goal] {
        return goals.filter { $0.isCompleted }.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func updateGoalProgress(_ goal: Goal, habit: Habit) {
        goal.updateProgress(count: habit.doneDates.count)
    }
    
    func checkMilestones(_ goal: Goal) {
        for milestone in goal.milestones where !milestone.isCompleted {
            if goal.currentCount >= milestone.targetValue {
                milestone.complete()
            }
        }
    }
    
    func deleteGoal(_ goal: Goal, context: ModelContext) {
        context.delete(goal)
        try? context.save()
    }
}
