import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: CategoryListViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                List(viewModel.categories) { category in
                    NavigationLink {
                        CategoryDetailWrapperView(
                            viewModel: viewModel,
                            categorySet: category,
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
                            categorySet: CategorySet(
                                id: UUID(),
                                name: "",
                                icon: UserImageSlot(image: nil),
                                priority: .low,
                                frequency: .daily,
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
