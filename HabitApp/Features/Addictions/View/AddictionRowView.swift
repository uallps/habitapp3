import SwiftUI

struct AddictionRowView: View {
    let addiction: Addiction
    let addictionListVM: AddictionListViewModel
    @State private var showDeleteAlert = false
    
    @ViewBuilder
    var iOSBody: some View {
        HStack {
            commonBody
        }
    }

@ViewBuilder
var macOSBody: some View {
    NavigationLink {
        AddictionDetailWrapperView(
            addictionListVM: addictionListVM,
            addiction: addiction,
            habitListVM: HabitListViewModel(storageProvider: addictionListVM.storageProvider)
        )
    } label: {
        HStack {
            commonBody
        }
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
}


    @ViewBuilder
    var commonBody: some View {

            Text(addiction.title)
                .font(.headline)
            Spacer()
            Text("Severidad \(addiction.severity.rawValue) \(addiction.severity.emoji)")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text("Recaídas: \(addiction.relapseCount)")
                .font(.subheadline)
                .foregroundColor(.red)
            Spacer()
            Button {
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            .alert("Eliminar adicción", isPresented: $showDeleteAlert) {
                            Button("Eliminar", role: .destructive) {
                                Task {
                                    await addictionListVM.deleteAddiction(addiction: addiction)
                                }
                               
                            }
                            Button("Cancelar", role: .cancel) { }
                        } message: {
                            Text("¿Estás seguro de que quieres eliminar esta adicción?")
                        }    }

    var body: some View {
        #if os(iOS)
        iOSBody
        #else
        macOSBody
        #endif
    }
}
