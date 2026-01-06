import SwiftUI


struct HabitCategoryView: View {
    @StateObject var categoryListVM: CategoryListViewModel
    var body: some View {
        Section(header: Text("Añadir hábito a categoría")) {
            if Array(categoryListVM.categories).isEmpty {
                Text("No hay categorías disponibles. Crea al menos una categoría.")
                    .foregroundColor(.gray)
                
            }else {
                List {
                    ForEach(Array(categoryListVM.categories).sorted(by: { $0.name < $1.name })) { category in
                        NavigationLink {
                            CategoryDetailWrapperView(
                                storageProvider: categoryListVM.storageProvider,
                                category: category,
                                isSubcategory: category.isSubcategory
                            )
                        } label: {
                            CategoryRowView(
                                storageProvider: categoryListVM.storageProvider,
                                category: category
                            )
                            
                        }
                        .buttonStyle(.plain)
                        
                    }
                }
                .frame(minHeight: 120, maxHeight: 300)
            }
        }.task {
            await categoryListVM.loadCategories()
        }
    }
    
    init(storageProvider: StorageProvider) {
        self._categoryListVM = StateObject(wrappedValue: CategoryListViewModel(storageProvider: storageProvider))
    }
}


