import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: CategoryListViewModel
    @EnvironmentObject private var appConfig: AppConfig
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                List(Array(viewModel.categories.values).filter { !$0.isSubcategory }                ) { category in
                    NavigationLink {
                        CategoryDetailWrapperView(
                            storageProvider: appConfig.storageProvider,
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
                            storageProvider: appConfig.storageProvider,
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
}
