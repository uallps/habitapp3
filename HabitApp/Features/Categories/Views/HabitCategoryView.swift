import SwiftUI


struct HabitCategoryView: View {
    @StateObject var categoryListVM: CategoryListViewModel
    
    @ViewBuilder
    var listCategoriesSection : some View {
        List {
            ForEach(Array(categoryListVM.filteredCategories).sorted(by: { $0.name < $1.name })) { category in
                NavigationLink {
                    CategoryDetailWrapperView(
                        storageProvider: categoryListVM.storageProvider,
                        category: category,
                        isSubcategory: category.isSubcategory
                    )
                } label: {
                    CategoryRowView(category: category)
                    
                }
                .buttonStyle(.plain)
                
            }
        }
        .frame(minHeight: 120, maxHeight: 300)
    }
    
    var body: some View {
        Section(header: Text("Añadir hábito a categoría")) {
            if Array(categoryListVM.categories).isEmpty {
                Text("No hay categorías disponibles. Crea al menos una categoría.")
                    .foregroundColor(.gray)
                
            }else {
                listCategoriesSection
            }
        }.task {
            await categoryListVM.loadCategories()
        }
        

    }

            init(storageProvider: StorageProvider) {
            self._categoryListVM = StateObject(wrappedValue: CategoryListViewModel(storageProvider: storageProvider))
        }
    
    
}
