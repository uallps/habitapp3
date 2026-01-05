import Foundation
import Combine

class ObservableCategory: ObservableObject, Identifiable {
    let id: UUID
    @Published var category: Category
    
    init(id: UUID = UUID(), category: Category) {
        self.id = id
        self.category = category
    }
}

