import Foundation
import Combine

class CategoryListViewModel: ObservableObject {
    @Published var categories: [String: Category] = [

    ]
    
    func addCategory(category: Category) {
        categories[category.name] = category
    }
}
