import SwiftUI
import _SwiftData_SwiftUI

struct AddictionListView: View {
    @Query var addictions: [Addiction]
    @StateObject var addictionListVM: AddictionListViewModel
    
    init(storageProvider: StorageProvider) {
        self._addictionListVM = StateObject(wrappedValue: AddictionListViewModel(storageProvider: storageProvider))
        
    }
    
    var body: some View {
        iOSBody
    }
    
    @ViewBuilder
    var iOSBody: some View {
        VStack(spacing: 12) {
            NavigationStack {
                List(Array(addictions)) { addiction in
                    NavigationLink {
                        AddictionDetailWrapperView(
                            addictionListVM: addictionListVM,
                            addiction: addiction,
                            isNew: false,
                            habitListVM: HabitListViewModel(storageProvider: addictionListVM.storageProvider)
                        )
                    } label: {
                        AddictionRowView(
                            addiction: addiction,
                            addictionListVM: addictionListVM
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Adicciones")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        NavigationLink {
                            let addiction = Addiction(
                                title: "",
                                addiction: Habit(
                                    title: ""
                                )
                            )
                            AddictionDetailWrapperView(
                                addictionListVM: addictionListVM,
                                addiction: addiction,
                                habitListVM: HabitListViewModel(storageProvider: addictionListVM.storageProvider)
                            )
                        } label: {
                            Label("Añadir", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
    

}
