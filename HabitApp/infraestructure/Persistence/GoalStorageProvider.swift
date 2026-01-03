import Foundation
protocol GoalStorageProvider {
    func loadGoals() async throws -> [Goal]
    func saveGoals(goals: [Goal]) async throws
    func loadGoalsForHabit(habitId: UUID) async throws -> [Goal]
}