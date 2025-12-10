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

    init(context: ModelContext) {
        self.context = context
    }

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {

        guard let habit = try? context.fetch(FetchDescriptor<Habit>(predicate: #Predicate { $0.id == taskId })).first else { return }

        // Para cada Goal asociado actualizamos progreso
        for goal in habit.goals {
            goal.updateProgress(count: habit.doneDates.count)

            // Chequeo de hitos
            for milestone in goal.milestones where !milestone.isCompleted {
                if goal.currentCount >= milestone.targetValue {
                    milestone.complete()
                }
            }
        }

        try? context.save()
    }
}
