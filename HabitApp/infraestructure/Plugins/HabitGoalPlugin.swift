//
//  HabitGoalPlugin.swift
//  HabitApp
//
//  Created by Aula03 on 10/12/25.
//

import SwiftData
import Foundation

final class HabitGoalPlugin: TaskDataObservingPlugin {
    let context: ModelContext
    private let goalStorageProvider: GoalStorageProvider

    init(context: ModelContext) {
        self.context = context
        self.goalStorageProvider = SwiftDataGoalStorageProvider()
    }

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        guard let habit = try? context.fetch(FetchDescriptor<Habit>(predicate: #Predicate { $0.id == taskId })).first else { return }

        Task {
            do {
                let goals = try await goalStorageProvider.loadGoalsForHabit(habitId: habit.id)
                
                for goal in goals {
                    goal.updateProgress(count: habit.doneDates.count)

                    // Chequeo de hitos
                    for milestone in goal.milestones where !milestone.isCompleted {
                        if goal.currentCount >= milestone.targetValue {
                            milestone.complete()
                        }
                    }
                }
                
                try await goalStorageProvider.saveGoals(goals: goals)
            } catch {
                print("Error updating goals: \(error)")
            }
        }
    }
}
