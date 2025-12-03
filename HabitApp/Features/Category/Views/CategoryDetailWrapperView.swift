import SwiftUI

struct CategoryDetailWrapperView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CategoryListViewModel
    @State var categorySet: CategorySet
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Título de la categoría", text: $categorySet.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                viewModel.addCategory(category: categorySet)
                dismiss()
            }) {
                Text("Guardar categoría")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            }
            .background(Color.blue)
            .cornerRadius(10)
        }
        .navigationTitle("Nueva categoría")
        .padding()
    }
}
