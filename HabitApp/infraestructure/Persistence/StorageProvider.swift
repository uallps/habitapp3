protocol StorageProvider {
    func loadHabits() async throws -> [Habit]
    func saveHabits(habits: [Habit]) async throws
}
