import SwiftUI
import _SwiftData_SwiftUI

struct CategoryListView: View {
    @StateObject var categoryListVM: CategoryListViewModel
    @Query var categoriesQuery: [Category]
    @Environment(\.modelContext) private var modelContext
    
    init(storageProvider: StorageProvider) {
        _categoryListVM = StateObject(wrappedValue: CategoryListViewModel(storageProvider: storageProvider))
    }
    
    var body: some View {
#if os(iOS)
        iOSBody
#else
        macOSBody
#endif
    }
    
#if os(iOS)
@ViewBuilder
var iOSBody: some View {
    NavigationStack {
        VStack(spacing: 12) {
            List(Array(categoriesQuery).filter { !$0.isSubcategory }                ) { category in
                NavigationLink {
                    CategoryDetailWrapperView(
                        storageProvider: categoryListVM.storageProvider,
                        category: category,
                        isSubcategory: category.isSubcategory
                    )
                } label: {
                    CategoryRowView(
                        storageProvider: categoryListVM.storageProvider,
                        category: category,
                        isCategoryParentView: true
                    )
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
    }
}

    
#else
    @ViewBuilder
    var macOSBody: some View {
        NavigationStack {
            VStack(spacing: 12) {
                List(Array(categoriesQuery).filter { !$0.isSubcategory }) { category in
                    NavigationLink {
                        CategoryDetailWrapperView(
                            storageProvider: categoryListVM.storageProvider,
                            category: category,
                            isSubcategory: category.isSubcategory
                        )
                    } label: {
                        CategoryRowView(
                            storageProvider: categoryListVM.storageProvider,
                            category: category,
                            isCategoryParentView: true
                        )
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
        }
    }
#endif
    
}
