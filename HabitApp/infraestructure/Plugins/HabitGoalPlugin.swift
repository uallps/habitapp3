//
//  HabitGoalPlugin.swift
//  HabitApp
//
//  Created by Aula03 on 10/12/25.
//

import SwiftData
import Foundation

final class HabitGoalPlugin: TaskDataObservingPlugin {
    let storageProvider: StorageProvider

    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        guard let habit = try? storageProvider.context.fetch(FetchDescriptor<Habit>(predicate: #Predicate { $0.id == taskId })).first else { return }

        do {
            let habitId = habit.id
            let goalDescriptor = FetchDescriptor<Goal>(
                predicate: #Predicate<Goal> { goal in
                    goal.habitId == habitId
                }
            )
            let goals = try storageProvider.context.fetch(goalDescriptor)
            
            for goal in goals {
                goal.updateProgress(count: habit.doneDates.count)

                for milestone in goal.milestones where !milestone.isCompleted {
                    if goal.currentCount >= milestone.targetValue {
                        milestone.complete()
                    }
                }
            }
            
            try storageProvider.context.save()
        } catch {
            print("Error updating goals: \(error)")
        }
    }
}