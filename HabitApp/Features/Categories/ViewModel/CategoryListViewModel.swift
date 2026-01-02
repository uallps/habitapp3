import Foundation
import Combine
import SwiftData

class CategoryListViewModel: ObservableObject {

    @Published var categories: [UUID: Category] = [:]
    private var modelContext: ModelContext?

    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadCategories()
    }
    
    func loadCategories() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        
        do {
            let fetchedCategories = try modelContext.fetch(descriptor)
            
            // Transformar el array en un diccionario con clave por el UUID
            categories = Dictionary(
                uniqueKeysWithValues: fetchedCategories.map { ($0.id, $0) }
            )
        } catch {
            print("Error loading categories: \(error)")
        }
    }
    
    func addCategory(category: Category) {
        categories[category.id] = category
    }

    func addSubCategory(category: Category, subCategory: Category) {
        categories[category.id]?.subCategories[subCategory.name] = subCategory
    }

    func removeCategory(category: Category) {
        categories.removeValue(forKey: category.id)
    }

    func removeSubCategory(category: Category, subCategory: Category) {
        categories[category.id]?.subCategories.removeValue(forKey: subCategory.name)
    }

    func categoryExists(id: UUID) -> Bool {
        return categories[id] != nil
    }

    func updateCategory(id: UUID, newCategory: Category) {
        
        if let category = categories[id] {
            // Eliminar la categoría antigua si el nombre ha cambiado.
            if category.name != newCategory.name {
                categories.removeValue(forKey: id)
            }
            // Añadir o actualizar la categoría con el nuevo nombre.
            categories[id] = newCategory
        }

    }
    
    func upsertCategoryOrSubcategory(parent: Category?, category: Category) {
        if let parent = parent {
            addSubCategory(category: parent, subCategory: category)
        }
        
            if categoryExists(id: category.id) == false {
                                addCategory(category: category)
                            }else {
                                // Actualizar categoría existente
                                updateCategory(id: category.id, newCategory: category)
                            }    }}        
        

