//
//  HabitGoalPlugin.swift
//  HabitApp
//
//  Created by Aula03 on 10/12/25.
//

import SwiftData
import Foundation

final class HabitGoalPlugin: TaskDataObservingPlugin {
    
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    let config: AppConfig
    
    init(config: AppConfig) {
        self.isEnabled = AppConfig.enableGoals
        self.models = [Habit.self, Goal.self, Milestone.self]
        self.config = config
    }
    

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        Task {
            try await config.storageProvider.onDataChanged(taskId: taskId, title: title, dueDate: dueDate)
        }
    }
}
