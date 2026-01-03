import Foundation
import SwiftData

class SwiftDataContext {
    static var shared: ModelContext?
}

class SwiftDataStorageProvider: StorageProvider {

    private let modelContainer: ModelContainer
    let context: ModelContext

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
        let descriptor = FetchDescriptor<Habit>()
        let tasks = try context.fetch(descriptor)
        return tasks
    }

    func saveTasks(tasks: [Habit]) async throws {
        let existingTasks = try await self.loadTasks()
        let existingIds = Set(existingTasks.map { $0.id })
        let newIds = Set(tasks.map { $0.id })
        
        for existingTask in existingTasks where !newIds.contains(existingTask.id) {
            context.delete(existingTask)
        }
        
        for task in tasks {
            if existingIds.contains(task.id) {
            } else {
                context.insert(task)
            }
        }
        
        try context.save()
    }
}