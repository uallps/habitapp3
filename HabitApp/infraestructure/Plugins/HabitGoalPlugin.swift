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

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?, doneDates: [Date]?) {
        
        //  Usar el contexto principal en lugar de crear uno nuevo
        let context = storageProvider.context
        
        //  Forzar rollback y refetch desde el almacenamiento persistente
        context.rollback()
        
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate<Habit> { $0.id == taskId }
        )
        
        guard let habit = try? context.fetch(descriptor).first else {
            return
        }

        do {
            let habitId = habit.id
            print("🔍 Hábito encontrado: '\(habit.title)' - doneDatesString: '\(habit.doneDatesString)'")
            
            let goalDescriptor = FetchDescriptor<Goal>(
                predicate: #Predicate<Goal> { goal in
                    goal.habitId == habitId
                }
            )
            let goals = try context.fetch(goalDescriptor)
            
           
            for goal in goals {
                goal.updateProgress(count: habit.doneDates.count)

                for milestone in goal.milestones where !milestone.isCompleted {
                    if goal.currentCount >= milestone.targetValue {
                        milestone.complete()
                    }
                }
            }
            
            try context.save()
        } catch {
        }
    }
}
