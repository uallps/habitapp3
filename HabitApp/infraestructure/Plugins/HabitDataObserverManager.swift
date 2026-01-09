//
//  TaskDataObserverManager.swift
//  HabitApp
//
//  Created by Aula03 on 10/12/25.
//
import Foundation
final class HabitDataObserverManager {
    static let shared = HabitDataObserverManager()
    private init() {}

    private var plugins: [HabitDataObservingPlugin] = []

    func register(_ plugin: HabitDataObservingPlugin) {
        plugins.append(plugin)
    }

    func notify(taskId: UUID, title: String, date: Date?) {
        plugins.forEach { $0.onDataChanged(taskId: taskId, title: title, dueDate: date) }
    }
}
