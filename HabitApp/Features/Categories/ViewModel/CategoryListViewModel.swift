import Foundation
import Combine

class CategoryListViewModel: ObservableObject {

    // String es el nombre de la categoría, que es único.
    @Published var categories: [String: Category] = [:]
    
    func addCategory(category: Category) {
        categories[category.name] = category
    }

    func addSubCategory(category: Category, subCategory: Category) {
        categories[category.name]?.subCategories[subCategory.name] = subCategory
    }

    func removeCategory(category: Category) {
        categories.removeValue(forKey: category.name)
    }

    func removeSubCategory(category: Category, subCategory: Category) {
        categories[category.name]?.subCategories.removeValue(forKey: subCategory.name)
    }

    func categoryExists(name: String) -> Bool {
        return categories[name] != nil && !name.isEmpty
    }

    func updateCategory(oldName: String, newCategory: Category) {
        // Eliminar la categoría antigua si el nombre ha cambiado.
        if oldName != newCategory.name {
            categories.removeValue(forKey: oldName)
        }
        // Añadir o actualizar la categoría con el nuevo nombre.
        categories[newCategory.name] = newCategory
    }
    
    func upsertCategoryOrSubcategory(categoryName: String, parent: Category?, category: Category) {
        if let parent = parent {
            addSubCategory(category: parent, subCategory: category)
        }else {
                                    if categoryExists(name: categoryName) == false {
                                addCategory(category: category)
                            }else {
                                // Actualizar categoría existente
                            updateCategory(oldName: categoryName, newCategory: category)
                            }
        }
    }}
