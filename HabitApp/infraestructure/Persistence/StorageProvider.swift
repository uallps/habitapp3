import SwiftData

protocol StorageProvider {
    var context: ModelContext { get }
    func loadTasks() async throws -> [Habit]
    func saveTasks(tasks: [Habit]) async throws
}