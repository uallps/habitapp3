import Foundation

protocol StorageProvider {
    func loadHabits() async throws -> [Habit]
    func saveHabits(habits: [Habit]) async throws
    func loadCategories() async throws -> [UUID:Category]
}
