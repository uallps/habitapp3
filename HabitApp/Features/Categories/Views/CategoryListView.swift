import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: CategoryListViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                List(viewModel.categories) { category in
                    NavigationLink(value: category) {
                        CategoryRowView(
                            category: category
                        )
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
                                colorAssetName: "AccentColor",
                                icon: UserImageSlot(image: nil),
                                priority: .low,
                                frequency: .daily
                            )
                        )
                    } label: {
                        Label("Añadir", systemImage: "plus")
                    }
                }
            })
        }
    }
}
