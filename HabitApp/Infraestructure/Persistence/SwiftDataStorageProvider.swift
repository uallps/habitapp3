import Foundation
import _SwiftData_SwiftUI
import SwiftData

class SwiftDataContext {
    static var shared: ModelContext?
}

class SwiftDataStorageProvider: StorageProvider {
    
    var modelContainer: ModelContainer
    private var context: ModelContext
    
    init(schema: Schema) {
        do {
            self.modelContainer = try ModelContainer(for: schema)
            self.context = ModelContext(self.modelContainer)
            SwiftDataContext.shared = self.context
        } catch {
            fatalError("Failed to initialize storage provider: \(error)")
        }
    }
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.context = modelContainer.mainContext
        SwiftDataContext.shared = self.context
    }
    
    // MARK: - Habit Methods
    
    @MainActor
    func getHabit(id: UUID) async throws -> Habit? {
        let habitPredicate = #Predicate<Habit> { $0.id == id }
        let habitDescriptor = FetchDescriptor<Habit>(predicate: habitPredicate)
        guard let habit = try context.fetch(habitDescriptor).first else {
            return nil
        }
        return habit
    }
    
    @MainActor
    func loadHabits() async throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        let habits = try context.fetch(descriptor)
        return habits
    }

    @MainActor
    func saveHabits(habits: [Habit]) async throws {
        let existingHabits = try await self.loadHabits()
        let existingIds = Set(existingHabits.map { $0.id })
        let newIds = Set(habits.map { $0.id })
        
        for existingHabit in existingHabits where !newIds.contains(existingHabit.id) {
            context.delete(existingHabit)
        }
        
        for habit in habits {
            if !existingIds.contains(habit.id) {
                context.insert(habit)
            }
        }
        
        try context.save()
    }
    
    @MainActor
    func addHabit(habit: Habit) async throws {
        do {
            try context.insert(habit)
            try await saveContext()
        } catch {
            print("Error adding habit: \(error)")
        }
    }
    
    @MainActor
    func deleteHabit(habit: Habit) async throws {
        do {
            if let realHabit = getRealInstanceHabit(habit) {
                try context.delete(realHabit)
                try await saveContext()
            }
        } catch {
            print("Error deleting habit: \(error)")
        }
    }
    
    @MainActor
    private func getRealInstanceHabit(_ habit: Habit) -> Habit? {
        do {
            let habitID = habit.id
            let descriptor = FetchDescriptor<Habit>(
                predicate: #Predicate<Habit> { storedHabit in
                    storedHabit.id == habitID
                }
            )
            return try context.fetch(descriptor).first
        } catch {
            print("Error getting real instance of Habit: \(error)")
            return nil
        }
    }
    
    // MARK: - Achievements
    
    @MainActor
    func loadAchievements() async throws -> [Achievement] {
        print("📂 Cargando logros desde SwiftData...")
        let descriptor = FetchDescriptor<Achievement>(
            sortBy: [SortDescriptor(\.unlockedAt, order: .reverse)]
        )
        let achievements = try context.fetch(descriptor)
        print("📊 Logros encontrados: \(achievements.count)")
        achievements.forEach { print("  - \($0.achievementId): \($0.title)") }
        return achievements
    }
    
    @MainActor
    func saveAchievement(_ achievement: Achievement) async throws {
        print("💾 Insertando logro en contexto: \(achievement.achievementId)")
        context.insert(achievement)
        print("💾 Guardando contexto...")
        try context.save()
        print("✅ Contexto guardado exitosamente")
    }
    
    @MainActor
    func deleteAchievement(_ achievement: Achievement) async throws {
        context.delete(achievement)
        try context.save()
    }
    
    // MARK: - General Context Methods
    
    @MainActor
    func saveContext() async throws {
        do { try context.save() }
        catch { print("Error guardando contexto: \(error)") }
    }
    
    // MARK: - Dev/Test Methods
    
    @MainActor
    func resetStorage() {
        SwiftDataContext.shared = nil
        do {
            let newContainer = try ModelContainer(for: Schema())
            let newContext = ModelContext(newContainer)
            self.modelContainer = newContainer
            self.context = newContext
            SwiftDataContext.shared = newContext
            print("✅ SwiftData storage reset complete.")
        } catch {
            print("❌ Failed to reset SwiftData storage: \(error)")
        }
    }
    
    static func resetStore(schema: Schema) {
        do {
            let container = try ModelContainer(for: schema)
            try container.deleteAllData()
            print("SwiftData store reset")
        } catch {
            print("SwiftData reset failed: \(error)")
        }
    }
    
    static func deleteStoreFile() {
        let url = URL.applicationSupportDirectory
            .appending(path: "HabitApp.store")
        try? FileManager.default.removeItem(at: url)
    }
}
