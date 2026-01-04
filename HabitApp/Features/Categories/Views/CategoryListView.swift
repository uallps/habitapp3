import SwiftUI

struct CategoryListView: View {
    @StateObject var categoryListVM: CategoryListViewModel
    
    init(storageProvider: StorageProvider) {
        _categoryListVM = StateObject(wrappedValue: CategoryListViewModel(storageProvider: storageProvider))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                List(Array(categoryListVM.categories.values).filter { !$0.isSubcategory }                ) { category in
                    NavigationLink {
                        CategoryDetailWrapperView(
                            storageProvider: categoryListVM.storageProvider,
                            category: category,
                            isSubcategory: category.isSubcategory
                        )
                    } label: {
                        CategoryRowView(category: category)
                    }
                    

                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Categorías")
            .toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    NavigationLink {
                        let category = Category(
                            id: UUID(),
                            name: "",
                            icon: UserImageSlot(image: nil),
                            priority: .low,
                            isSubcategory: false
                        )
                        CategoryDetailWrapperView(
                            storageProvider: categoryListVM.storageProvider,
                            category: category,
                            isSubcategory: category.isSubcategory
                        )
                    } label: {
                        Label("Añadir", systemImage: "plus")
                    }
                }
            })
        }.task {
            await categoryListVM.loadCategories()
        }
    }
}
