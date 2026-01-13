import SwiftUI

struct CategoryRowView: View {
    
    let category: Category
    let habit: Habit?
    
    @StateObject var categoryListVM: CategoryListViewModel
    @StateObject var userImagesVM: UserImagesViewModel
    @State private var showingDeleteAlert = false
    private var isCategoryParentView = false
    @State private var isHabitAddedToCategory = false
    @State private var isImageLoaded = false
    @State private var image: PlatformImage? = nil
    
    init(storageProvider: StorageProvider, category: Category, isCategoryParentView: Bool, habit: Habit? = nil, isHabitAddedToCategory: Bool = false, userImageSlot: UserImageSlot) {
        self._categoryListVM = StateObject(wrappedValue: CategoryListViewModel(storageProvider: storageProvider))
        self._userImagesVM = StateObject(wrappedValue: UserImagesViewModel(storageProvider: storageProvider, userImageSlot: userImageSlot))
        self.category = category
        self.isCategoryParentView = isCategoryParentView
        self.habit = habit
        self.isHabitAddedToCategory = false
    }
    
    var body: some View {
        
        HStack {
            // El nombre de la categoría se almacena en minúsculas, pero se muestra con la primera letra en mayúsculas.
            Text(category.name)
            
            Circle()
                .fill(category.color)
                .frame(width: 26, height: 26)
                .overlay(
                    Circle().stroke(Color.black, lineWidth: 1)
                )
            
            Group {
                let image = userImagesVM.image
                if image != nil {
#if os(iOS)
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 46, height: 46)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 1)
                        )
#elseif os(macOS)
                    Image(nsImage: image!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 46, height: 46)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: 1)
                        )
#endif
                } else {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 50, height: 40)
                        .overlay(
                            HStack(spacing: 0) {
                                ForEach(category.icon.emojis ?? [], id: \.self) { emoji in
                                    Text(emoji.emoji)
                                        .font(.title2)
                                }
                            }
                        )
                        .overlay(
                            Capsule().stroke(Color.black, lineWidth: 1)
                        )
                }
            }
            .task {
                do {
                    let loadedImage = try await userImagesVM.storageProvider.loadPickedImage(userImagesVM.userImageSlot).image
                    await MainActor.run {
                        self.image = loadedImage
                    }
                } catch {
                    print("Failed to load image: \(error)")
                    await MainActor.run {
                        self.image = nil
                    }
                }
            }

            
            HStack() {
                #if os(macOS)
                Text(
                    "Prioridad: " + category.priority.emoji
                )
                #else
                Text(
                    "P:" + category.priority.emoji
                )
                #endif
            }
                    
            Spacer()
            
            if(isCategoryParentView) {
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
                .buttonStyle(.borderless)
                .alert("¿Eliminar categoría?", isPresented: $showingDeleteAlert) {
                    Button("Eliminar", role: .destructive) {
                        Task { @MainActor in
                            await categoryListVM.removeCategory(category: category)
                        }
                        showingDeleteAlert = false
                    }
                    Button("Cancelar", role: .cancel) {
                        showingDeleteAlert = false
                    }
                } message: {
                    Text("Esta acción no se puede deshacer. Se eliminarán subcategorías")
                }
            } else {
                if self.habit != nil && !isHabitAddedToCategory {
                    Button {
                        Task {
                            await categoryListVM.addHabitToCategory(
                                habit: habit!,
                                category: category
                            )
                            self.isHabitAddedToCategory = await categoryListVM.checkIfHabitIsInCategory(habit: habit!, category: category)
                        }
                        
                    } label: {
                        Label("Añadir a esta categoría", systemImage: "plus")
                    }
                }else if (isHabitAddedToCategory) {
                    Button {
                        Task {
                            await categoryListVM.deleteHabitFromCategory(habit: habit!, category: category)
                            self.isHabitAddedToCategory = await categoryListVM.checkIfHabitIsInCategory(habit: habit!, category: category)
                        }
                    } label: {
                        Label("Eliminar de categoría", systemImage: "trash")
                    }
                }
                

            }

        }
    }
}
