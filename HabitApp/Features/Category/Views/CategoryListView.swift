import SwiftUI

struct CategoryListView: View {
    @ObservedObject var viewModel: CategoryListViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
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
                                icon: UserImageSlot(image: nil, id: ""),
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
