protocol StorageProvider {
    func loadTasks() async throws -> [Habit]
    func saveTasks(tasks: [Habit]) async throws
}