import Foundation
import SwiftData

class SwiftDataContext {
    static var shared: ModelContext?
}

class SwiftDataStorageProvider: StorageProvider {
    func loadPickedImage() async throws -> UserImageSlot {
        var fetchedImage: UserImageSlot? = nil
        let descriptor = FetchDescriptor<UserImageSlot>(
            sortBy: [SortDescriptor(\.id, order: .forward)]
        )
        
        do {
            fetchedImage = try context.fetch(descriptor).first
        } catch {
            print("Error loading picked image: \(error)")
        }
        let noImageArray: [Emoji] = []
        return fetchedImage ?? UserImageSlot(emojis: noImageArray)
    }
    
    func addHabitToCategory(habit: Habit, category: Category) async throws {
        if !category.habits.contains(where: { $0.id == habit.id } ) {
            category.habits.append(habit)
        }
        try context.save()
    }
    
    func addSubcategory(category: Category, subCategory: Category) async throws {
        if subCategory.modelContext == nil {
            context.insert(subCategory)
        }

        if !category.subCategories.contains(where: { $0.id == subCategory.id }) {
            category.subCategories.append(subCategory)
        }
        
        try context.save()
    }
    
    func removeCategory(category: Category) async throws {
        context.delete(category)
    }
    
    func removeSubCategory(category: Category, subCategory: Category) async throws {
        if subCategory.modelContext != nil {
            let index = category.subCategories.firstIndex(of: subCategory)
            if index != nil {
                category.subCategories.remove(at: index! )
                context.delete(subCategory)
            }
        }
    }
    
    func categoryExists(id: UUID) async throws -> Bool {
        let categories = try await loadCategories()
        return categories.contains(where: { $0.id == id } )
    }
    
    func updateCategory(id: UUID, newCategory: Category) async throws {
        let categories = try await loadCategories()
        let oldCategory = categories.first {
            category in
            category.id == id
        }
        oldCategory?.copyFrom(newCategory: newCategory)
        try context.save()
    }
    
    func upsertCategoryOrSubcategory(parent: Category?, category: Category) async throws {
        if let parent = parent {
            try await addSubcategory(category: parent, subCategory: category)
        }
        
        if try await categoryExists(id: category.id) == false {
            await addCategory(category: category)
        }else {
            // Actualizar categoría existente
            try await updateCategory(id: category.id, newCategory: category)
        }
    }
    

    private var modelContainer: ModelContainer
    private var context: ModelContext

    init(schema: Schema) {
        do {
            // Schema conflict dev temp solution
            //SwiftDataStorageProvider.resetStore(schema: schema)
            //SwiftDataStorageProvider.deleteStoreFile()
            self.modelContainer = try ModelContainer(for: schema)
            self.context = ModelContext(self.modelContainer)
            SwiftDataContext.shared = self.context
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
    func loadCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        
        var categories: [Category] = []
        
        do {
            categories = try context.fetch(descriptor)
        } catch {
            print("Error loading categories: \(error)")
        }
        return categories
    }
    
    func addCategory(category: Category) async {
        do {
            let existingCategories = try await loadCategories()
            let existingIds = Set(existingCategories.map { $0.id })

            if existingIds.contains(category.id) {
                // Category already exists
                // Option 1: do nothing
                // Option 2: update properties explicitly if needed
            } else {
                context.insert(category)
            }
        } catch {
            print("Error saving category: \(error)")
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
    }}




