import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: CategoryListViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                List(Array(viewModel.categories.values).filter { !$0.isSubcategory }                ) { category in
                    NavigationLink {
                        CategoryDetailWrapperView(
                            viewModel: viewModel,
                            category: category,
                            userImageVM: UserImagesViewModel(),
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
                            viewModel: viewModel,
                            category: category,
                            userImageVM: UserImagesViewModel(),
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
