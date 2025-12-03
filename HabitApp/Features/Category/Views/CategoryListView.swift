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
                            categorySet: CategorySet(name: "", icon: UserImageSlot(image: nil), priority: .low, frequency: .daily)
                        )
                    } label: {
                        Label("Añadir", systemImage: "plus")
                    }
                }
            })
        }
    }
}
