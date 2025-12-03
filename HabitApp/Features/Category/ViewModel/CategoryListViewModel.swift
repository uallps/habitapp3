import Foundation
import Combine

class CategoryListViewModel: ObservableObject {
    @Published var categories: [CategorySet] = [

    ]
    
    func addHabit(category: CategorySet) {
        categories.append(category)
    }
}
