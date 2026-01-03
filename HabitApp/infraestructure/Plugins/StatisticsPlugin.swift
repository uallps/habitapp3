//
//  StatisticsPlugin.swift
//  HabitApp
//
//  Created by Copilot on 03/01/26.
//

import Foundation

final class StatisticsPlugin: TaskDataObservingPlugin {
    weak var viewModel: StatisticsViewModel?
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
    }
    
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        // Cuando cambia un hábito, recargar estadísticas
        viewModel?.loadStatistics()
    }
}
