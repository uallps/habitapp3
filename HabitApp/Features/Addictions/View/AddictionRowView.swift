import SwiftUI

struct AddictionRowView: View {
    let addiction: Addiction
    let addictionListVM: AddictionListViewModel

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

    }

    var body: some View {
        #if os(iOS)
        iOSBody
        #else
        macOSBody
        #endif
    }
}
