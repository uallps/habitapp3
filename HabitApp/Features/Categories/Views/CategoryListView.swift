import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: CategoryListViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                List(Array(viewModel.categories.values)) { category in
                    NavigationLink {
                        CategoryDetailWrapperView(
                            viewModel: viewModel,
                            category: category,
                            userImageVM: UserImagesViewModel()
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
                        CategoryDetailWrapperView(
                            viewModel: viewModel,
                            category: Category(
                                id: UUID(),
                                name: "",
                                icon: UserImageSlot(image: nil),
                                priority: .low,
                            ),
                            userImageVM: UserImagesViewModel()
                        )
                    } label: {
                        Label("Añadir", systemImage: "plus")
                    }
                }
            })
        }
    }
}
