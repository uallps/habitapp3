import Foundation
//
//  PluginRegistry .swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

final class PluginRegistry {
    static let shared = PluginRegistry()
    
    private var plugins: [TaskDataObservingPlugin] = []
    
    private init() {}
    
    func register(plugin: TaskDataObservingPlugin) {
        plugins.append(plugin)
        print("✅ Plugin registrado: \(type(of: plugin))")
    }
    
    func notifyDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        print("🔔 Notificando \(plugins.count) plugins sobre cambio en: \(title)")
        plugins.forEach { plugin in
            plugin.onDataChanged(taskId: taskId, title: title, dueDate: dueDate)
        }
    }
}
