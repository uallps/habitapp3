import SwiftUI
import _SwiftData_SwiftUI


struct HabitCategoryView: View {
    @StateObject var categoryListVM: CategoryListViewModel
    @Query var categoriesQuery: [Category]
    var habit: Habit
    
    var body: some View {
        Section(header: Text("Categorías")) {
            if categoriesQuery.isEmpty {
                Text("No hay categorías disponibles. Crea al menos una categoría.")
                    .foregroundColor(.gray)
            }else {
                List {
                    ForEach(categoriesQuery.sorted(by: { $0.name < $1.name })) { category in
                            
                            CategoryRowView(
                                storageProvider: categoryListVM.storageProvider,
                                category: category,
                                isCategoryParentView: false,
                                habit: habit,
                                isHabitAddedToCategory: category.habits.contains(habit)
                            )
                            
                        .buttonStyle(.plain)
                        
                    }
                }
                .frame(minHeight: 120, maxHeight: 300)
            }
        }
    }
    
    init(storageProvider: StorageProvider, habit: Habit) {
        self._categoryListVM = StateObject(wrappedValue: CategoryListViewModel(storageProvider: storageProvider))
        self.habit = habit
    }
}


