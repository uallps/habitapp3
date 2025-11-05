import Foundation
import SwiftData

class SwiftDataStorageProvider: StorageProvider {

    static let shared = SwiftDataStorageProvider()

    private let modelContainer: ModelContainer
    private let context: ModelContext

    init(){
        do {
            self.modelContainer = try ModelContainer(for: Habit.self)
            self.context = ModelContext(self.modelContainer)
        } catch {
            fatalError("Failed to initialize storage provider: \(error)")
       }
    }

    func loadHabits() async throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>() // Use FetchDescriptor
        let habits = try context.fetch(descriptor)
        return habits
    }

    func saveHabits(habits: [Habit]) async throws {
        let savedHabits = try await self.loadHabits()
        for habit in savedHabits {
            context.delete(habit)
        }
        for habit in habits {
            context.insert(habit)
        }
        try context.save()
    }
}
