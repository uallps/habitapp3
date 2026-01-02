import Foundation
import SwiftData

class SwiftDataContext {
    static var shared: ModelContext?
}

class SwiftDataStorageProvider: StorageProvider {
    func addSubcategory(category: Category, subCategory: Category) async throws {
        if subCategory.modelContext == nil {
            context.insert(subCategory)
        }

        if !category.subCategories.contains(where: { $0.id == subCategory.id }) {
            category.subCategories.append(subCategory)
        }
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
        return categories.contains(where: { $0.key == id } )
    }
    
    func updateCategory(id: UUID, newCategory: Category) async throws {
        let categories = try await loadCategories()
        let oldCategory = categories[id]
        
    }
    
    func upsertCategoryOrSubcategory(parent: Category?, category: Category) async throws {
        <#code#>
    }
    

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
    
    func loadCategories() async throws -> [UUID : Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        
        var categoriesMap: [UUID:Category] = [:]
        
        do {
            let fetchedCategories = try context.fetch(descriptor)
            
            // Transformar el array en un diccionario con clave por el UUID
            categoriesMap = Dictionary(
                uniqueKeysWithValues: fetchedCategories.map { ($0.id, $0) }
            )
        } catch {
            print("Error loading categories: \(error)")
        }
        return categoriesMap
    }
    
    func addCategory(category: Category) async {
        do {
            let existingCategories = try await loadCategories()
            let existingIds = Set(existingCategories.map { $0.key })

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

}
