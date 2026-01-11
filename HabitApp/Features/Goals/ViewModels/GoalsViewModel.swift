import Foundation
import SwiftData
import Combine

final class GoalsViewModel: ObservableObject {
    private let storageProvider: StorageProvider
    @Published var goals: [Goal] = []
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
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
    
    func deleteGoal(_ goal: Goal) {
        Task {
            do {
                try await storageProvider.deleteGoal(goal)
                print("✅ Objetivo eliminado correctamente")
            } catch {
                print("❌ Error deleting goal: \(error)")
            }
        }
    }}
