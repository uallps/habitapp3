import Foundation

final class PluginRegistry {
    static let shared = PluginRegistry()
    private var plugins: [TaskDataObservingPlugin] = []

    func register(plugin: TaskDataObservingPlugin) {
        plugins.append(plugin)
    }

    func notifyDataChanged(taskId: UUID, title: String, dueDate: Date?, doneDates: [Date]?) {
        print("🔔 Notificando plugins con \(doneDates?.count ?? 0) fechas.")
        for plugin in plugins {
            plugin.onDataChanged(taskId: taskId, title: title, dueDate: dueDate, doneDates: doneDates)
        }
    }
}
