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
    
    func notifyDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        print("Notificando \(plugins.count) plugins sobre cambio en: \(title)")
        plugins.forEach { plugin in
            plugin.onDataChanged(taskId: taskId, title: title, dueDate: dueDate)
        }
    }
}
