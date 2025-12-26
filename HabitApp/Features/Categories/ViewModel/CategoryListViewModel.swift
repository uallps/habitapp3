import Foundation
import Combine

class CategoryListViewModel: ObservableObject {

    // String es el nombre de la categoría, que es único.
    @Published var categories: [String: Category] = [

    ]
    
    func addCategory(category: Category) {
        categories[category.name] = category
    }

    func addSubCategory(category: Category, subCategory: SubCategory) {
        categories[category.name]?.subCategories[subCategory.name] = subCategory
    }

    func removeCategory(category: Category) {
        categories.removeValue(forKey: category.name)
    }

    func removeSubCategory(category: Category, subCategory: SubCategory) {
        categories[category.name]?.subCategories.removeValue(forKey: subCategory.name)
    }

    func categoryExists(name: String) -> Bool {
        return categories[name] != nil
    }
}
