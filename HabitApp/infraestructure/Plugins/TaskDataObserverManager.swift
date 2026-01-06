//
//  TaskDataObserverManager.swift
//  HabitApp
//
//  Created by Aula03 on 10/12/25.
//
import Foundation
final class TaskDataObserverManager {
    static let shared = TaskDataObserverManager()
    private init() {}

    private var plugins: [TaskDataObservingPlugin] = []

    func register(_ plugin: TaskDataObservingPlugin) {
        plugins.append(plugin)
    }

    func notify(taskId: UUID, title: String, date: Date?) {
        plugins.forEach { $0.onDataChanged(taskId: taskId, title: title, dueDate: date) }
    }
}