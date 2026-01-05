import Foundation
import Combine
import SwiftData

class CategoryListViewModel: ObservableObject {
    @Published var categories: [ObservableCategory] = []
    
    var filteredCategories : [Category] {
        var categoriesArray: [Category] = []
        for observedCategory in categories {
            categoriesArray.append(observedCategory.category)
        }
        
        return categoriesArray
    }
    
    let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    func loadCategories() async {
        do {
            let fetchedCategories = try await storageProvider.loadCategories()
            categories = []
            for category in fetchedCategories {
                categories.append(
                    ObservableCategory(
                        category: category
                    )
                )
            }
        } catch {
            print("Error loading tasks: \(error)")
        }
    }
    
    func addCategory(category: Category) async {
        do {
            try await storageProvider.addCategory(category: category)
        } catch {
            print("Error adding category: \(error)")
        }
    }
    
    func addSubcategory(category: Category, subCategory: Category) async {
            do {
                try await storageProvider.addSubcategory(category: category, subCategory: subCategory)
            } catch {
              print("Error adding subcategory \(error)")
            }
        }
    
    func removeCategory(category: Category) async {
        do {
            try await storageProvider.removeCategory(category: category)
        } catch {
            print("Error removing category \(error)")
        }
    }
    
    func removeSubCategory(category: Category, subCategory: Category) async {
        do {
            try await storageProvider.removeSubCategory(category: category, subCategory: subCategory)
        } catch {
            print("Error removing subcategory \(error)")
        }
    }
    
    func categoryExists(id: UUID) async -> Bool {
        var contains = false
        do {
            contains = try await storageProvider.categoryExists(id: id)
        } catch {
            print("Error checking if category exists \(error)")
        }
        return contains
    }
    
    func updateCategory(id: UUID, newCategory: Category) async {
        do {
            try await storageProvider.updateCategory(id: id, newCategory: newCategory)
        } catch {
            print("Error updating category \(error)")
        }
    }
    
    func upsertCategoryOrSubcategory(parent: Category?, category: Category) async {
        do {
            try await storageProvider.upsertCategoryOrSubcategory(parent: parent, category: category)
        } catch {
            print("Error upserting category \(error)")
        }
    }
}
        

