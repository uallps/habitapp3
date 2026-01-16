import Foundation
import _SwiftData_SwiftUI
import SwiftData

class SwiftDataContext {
    static var shared: ModelContext?
}

class SwiftDataStorageProvider: StorageProvider {
    
    static private var _shared: SwiftDataStorageProvider?
    
    var modelContainer: ModelContainer
    private var context: ModelContext
    
    @MainActor
    init(schema: Schema) {
        // SIEMPRE crear un nuevo ModelContainer y contexto
        // No reutilizar anteriores porque pueden estar corruptos
        do {
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.modelContainer = try ModelContainer(for: schema, configurations: configuration)
            // Usar mainContext para que sea el mismo que usa SwiftUI
            self.context = self.modelContainer.mainContext
            // Compartir el contexto globalmente para que todos lo usen
            SwiftDataContext.shared = self.context
            // Guardar como singleton para reutilizar el MISMO container
            SwiftDataStorageProvider._shared = self
            print("SwiftDataContext.shared inicializado con mainContext NUEVO")
        } catch {
            // En caso de error de migración, intentar eliminar y recrear
            print("Error inicial de SwiftData: \(error)")
            print("Intentando recuperación eliminando store corrupto...")
            
            do {
                // Eliminar archivos de base de datos corruptos
                let fileManager = FileManager.default
                if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                    let storeURL = appSupport.appendingPathComponent("default.store")
                    try? fileManager.removeItem(at: storeURL)
                    try? fileManager.removeItem(at: storeURL.appendingPathExtension("shm"))
                    try? fileManager.removeItem(at: storeURL.appendingPathExtension("wal"))
                    print("Archivos de store eliminados")
                }
                
                // Reintentar creación
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                self.modelContainer = try ModelContainer(for: schema, configurations: configuration)
                self.context = self.modelContainer.mainContext
                SwiftDataContext.shared = self.context
                SwiftDataStorageProvider._shared = self
                print("SwiftData reinicializado correctamente después de limpieza")
            } catch {
                fatalError("Failed to initialize storage provider: \(error)")
            }
        }
    }
    
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
    func loadStreaksForHabit(habitId: UUID) async throws -> [Streak] {
        var streaks: [Streak] = []
        let predicate = #Predicate<Streak> { $0.habitId == habitId }
        let descriptor = FetchDescriptor<Streak>(predicate: predicate)
        streaks = try context.fetch(descriptor)
        return streaks
    }
    
    @MainActor
    func saveStreak(_ streak: Streak) async throws {
        context.insert(streak)
        try await saveContext()
        try await savePendingChanges()
    }
    
    @MainActor
    func updateStreak(_ streak: Streak) async throws {
        let streakId = streak.id
        let predicate = #Predicate<Streak> { $0.id == streakId }
        let descriptor = FetchDescriptor<Streak>(predicate: predicate)
        if let realStreak = try context.fetch(descriptor).first {
            realStreak.currentCount = streak.currentCount
            realStreak.lastUpdate = streak.lastUpdate
            try context.save()
        }
    }
    
    @MainActor
    func savePendingChanges() async throws {
        context.processPendingChanges()
    }
    
    @MainActor
    func saveContext() async throws {
        do { try context.save() }
        catch { print("Error guardando contexto: \(error)") }
   }
    
    // @MainActor
    // func updateNote(_ note: DailyNote, title: String, content: String) async throws {
    //     <#code#>
    // }
    
    // @MainActor
    // func saveAndGoToNoteDate(_ note: DailyNote, title: String, content: String) async throws {
    //     <#code#>
    // }
    
    @MainActor
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) async throws {
        //  Forzar rollback y refetch desde el almacenamiento persistente
        context.rollback()
        
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate<Habit> { $0.id == taskId }
        )
        
        guard let habit = try? context.fetch(descriptor).first else {
            return
        }
        
        do {
            let habitId = habit.id
            print("Hábito encontrado: '\(habit.title)' - doneDatesString: '\(habit.doneDatesString)'")
            
            try context.save()
        } catch {
            print("Error onDataChanged: \(error)")
        }
    }

    @MainActor
    private func getRealInstanceHabit(_ habit: Habit) -> Habit? {
        do {
            let habitID = habit.id

            let descriptor = FetchDescriptor<Habit>(
                predicate: #Predicate<Habit> { storedHabit in
                    storedHabit.id == habitID
                },
            )

            return try context.fetch(descriptor).first
        } catch {
            print("Error getting real instance of Habit: \(error)")
            return nil
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

    @MainActor
    func loadHabits() async throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>() // Use FetchDescriptor
        let habits = try context.fetch(descriptor)
        return habits
    }

    @MainActor
    func saveHabits(habits: [Habit]) async throws {
        let existingHabits = try await self.loadHabits()
        let existingIds = Set(existingHabits.map { $0.id })
        let newIds = Set(habits.map { $0.id })
        
        // Delete tasks not in the new list
        for existingHabit in existingHabits where !newIds.contains(existingHabit.id) {
            context.delete(existingHabit)
        }
        
        // Insert or update tasks
        for habit in habits {
            if existingIds.contains(habit.id) {
                // El hábito existe, asumir que está actualizado (ya que es el mismo objeto y sus propiedades no han cambiado)
            } else {
                context.insert(habit)
            }
        }
        
        try context.save()
    }
    
    @MainActor
    func addHabit(habit: Habit) async  throws {
        do {
            print("Antes de insertar - hasChanges: \(context.hasChanges)")
            context.insert(habit)
            print("Habit insertado: \(habit.title), hasChanges después insert: \(context.hasChanges)")
            
            // Si hasChanges sigue siendo false, el contexto está corrupto
            if !context.hasChanges {
                print("ADVERTENCIA: El contexto no detectó cambios. Intentando forzar...")
                context.processPendingChanges()
                print("Después processPendingChanges - hasChanges: \(context.hasChanges)")
            }
            
            try await saveContext()
            
            // Verificar que se guardó
            let descriptor = FetchDescriptor<Habit>()
            let allHabits = try context.fetch(descriptor)
            print("Total hábitos después de guardar: \(allHabits.count)")
            for h in allHabits {
                print("  - \(h.title)")
            }
        } catch {
            print("Error adding habit: \(error)")
            throw error
        }
    }
    
    // @MainActor
    // func updateHabit(habit: Habit) {
    //     do {
    //         try await storageProvider.context.save()
    //     } catch {
    //         print("Error updating habit: \(error)")
    //     }
    // }
    
    @MainActor
    func deleteHabit(habit: Habit) async throws {
        do {
            if let realHabit = getRealInstanceHabit(habit) {
                context.delete(realHabit)
                try await saveContext()
            }

        } catch {
            print("Error deleting habit: \(error)")
        }

    }
    
    // Este archivo existe para borrar toda la información de la base de datos local.
    // Es especialmente útil cuando existe un conflicto en los esquemas de un ordenador MacOS.

    // Como es evidente, tiene sentido en un entorno de desarrollo y pruebas. A no ser que
    //se quiera dejar una gran vulnerabilidad o trollear un poquito al usuario final, no
// debería de existir.
    @MainActor
    func resetStorage() {
        // 1. Tear down old context and container
        SwiftDataContext.shared = nil
        // Note: Old modelContainer will be deallocated automatically
        
        // 2. Recreate a new container and context
        do {
            let newContainer = try ModelContainer(for: Schema()) // your app schema
            let newContext = ModelContext(newContainer)
            self.modelContainer = newContainer
            self.context = newContext
            SwiftDataContext.shared = newContext
            print("SwiftData storage reset complete.")
        } catch {
            print("Failed to reset SwiftData storage: \(error)")
        }
    }
    
    static func resetStore(schema: Schema) {
        do {
            let container = try ModelContainer(for: schema)
            container.deleteAllData()
            print("SwiftData store reset")
        } catch {
            print("SwiftData reset failed: \(error)")
        }
    }
    
    static func deleteStoreFile() {
        let url = URL.applicationSupportDirectory
            .appending(path: "HabitApp.store")

        try? FileManager.default.removeItem(at: url)
    }}




