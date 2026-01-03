import Foundation
import SwiftData

class SwiftDataContext {
    static var shared: ModelContext?
}

class SwiftDataStorageProvider: StorageProvider {

    private let modelContainer: ModelContainer
    private let context: ModelContext

    init(schema: Schema) {
        do {
            self.modelContainer = try ModelContainer(for: schema)
            self.context = ModelContext(self.modelContainer)
            SwiftDataContext.shared = self.context
        } catch {
            fatalError("Failed to initialize storage provider: \(error)")
       }
    }

    func loadTasks() async throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>() // Use FetchDescriptor
        let tasks = try context.fetch(descriptor)
        return tasks
    }

    func saveTasks(tasks: [Habit]) async throws {
        let existingTasks = try await self.loadTasks()
        let existingIds = Set(existingTasks.map { $0.id })
        let newIds = Set(tasks.map { $0.id })
        
        // Delete tasks not in the new list
        for existingTask in existingTasks where !newIds.contains(existingTask.id) {
            context.delete(existingTask)
        }
        
        // Insert or update tasks
        for task in tasks {
            if existingIds.contains(task.id) {
                // Task exists, assume it's updated (since it's the same object or properties changed)
            } else {
                context.insert(task)
            }
        }
        
        try context.save()
    }
}