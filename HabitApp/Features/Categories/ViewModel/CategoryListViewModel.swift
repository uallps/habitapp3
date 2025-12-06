import Foundation
import Combine

class CategoryListViewModel: ObservableObject {
    @Published var categories: [CategorySet] = [

    ]
    
    func addCategory(category: CategorySet) {
        categories.append(category)
    }
}
