import SwiftUI

struct CategoryDetailWrapperView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CategoryListViewModel
    @State var category: Category

    private let parent: Category?

    @ObservedObject var userImageVM: UserImagesViewModel

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var activeSheet: ActiveSheet?

    private var isCategoryValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard selectedColor != nil else { return false }
        switch selectionMode {
        case .emoji:
            guard !selectedIconOne.emoji.isEmpty || !selectedIconTwo.emoji.isEmpty || !selectedIconThree.emoji.isEmpty else { return false }
        case .image:
            if userImageVM.image == nil { return false }
        }
        guard selectedPriority != nil else { return false }
        return true
    }

    // MARK: - Category State
    @State private var name: String = ""
    @State private var initialName: String = ""
    private var isSubCategory : Bool
    @State private var selectedIconOne: Emoji = Emoji(emoji: "", name: "", id: "")
    @State private var selectedIconTwo: Emoji = Emoji(emoji: "", name: "", id: "")
    @State private var selectedIconThree: Emoji = Emoji(emoji: "", name: "", id: "")
    @State private var newSub: Category? = Category(name: "", icon: UserImageSlot(image: nil), priority: .medium, isSubcategory: true)
    
    static let allColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown,
        .gray
    ]

    static let allColorsMap: [Color: String] = Dictionary(
        uniqueKeysWithValues: zip(
            allColors,
            [
                "red", "orange", "yellow", "green", "mint", "teal",
                "cyan", "blue", "indigo", "purple", "pink", "brown",
                "gray"
            ]
        )
    )

    @State private var selectedPriority: Priority? = nil
    @State private var selectedColor: Color? = nil

    enum SelectionMode: String, CaseIterable, Identifiable {
        case emoji = "Emoji"
        case image = "Imagen"
        var id: String { rawValue }
    }

    @State private var selectionMode: SelectionMode = .emoji
    
    init(viewModel: CategoryListViewModel, category: Category, userImageVM: UserImagesViewModel, parent: Category? = nil, isSubcategory: Bool) {
        self.viewModel = viewModel
        self._category = State(initialValue: category)
        self.userImageVM = userImageVM
        self.parent = parent
        self.isSubCategory = isSubcategory

        // Inicializar estado de categoría.
        
        self._initialName = State(initialValue: category.name.trimmingCharacters(in: .whitespacesAndNewlines).togglingFirstLetterCase)

        // Guardar nombre de la categoría siempre sin espacios y sin mayúsculas.
        self._name = State(initialValue: category.name.trimmingCharacters(in: .whitespacesAndNewlines).togglingFirstLetterCase)
        self._selectedPriority = State(initialValue: category.priority)
        self._selectedColor = State(initialValue: category.color)

        // Initialize icons
        if let emojis = category.icon.emojis, !emojis.isEmpty {
            self._selectedIconOne = State(initialValue: emojis.indices.contains(0) ? emojis[0] : Emoji(emoji: "", name: "", id: ""))
            self._selectedIconTwo = State(initialValue: emojis.indices.contains(1) ? emojis[1] : Emoji(emoji: "", name: "", id: ""))
            self._selectedIconThree = State(initialValue: emojis.indices.contains(2) ? emojis[2] : Emoji(emoji: "", name: "", id: ""))
            self._selectionMode = State(initialValue: .emoji)
        } else if category.icon.image != nil {
            self._selectedIconOne = State(initialValue: Emoji(emoji: "", name: "", id: ""))
            self._selectedIconTwo = State(initialValue: Emoji(emoji: "", name: "", id: ""))
            self._selectedIconThree = State(initialValue: Emoji(emoji: "", name: "", id: ""))
            self._selectionMode = State(initialValue: .image)
        } else {
            self._selectedIconOne = State(initialValue: Emoji(emoji: "", name: "", id: ""))
            self._selectedIconTwo = State(initialValue: Emoji(emoji: "", name: "", id: ""))
            self._selectedIconThree = State(initialValue: Emoji(emoji: "", name: "", id: ""))
            self._selectionMode = State(initialValue: .emoji)
        }
    }
    
    @ViewBuilder
    var nameAndIcon: some View {
        // MARK: - Name
        Section(header: Text("Nombre")) {
            TextField("Nombre de la categoría", text: $name)
        }
        
        Section("Color") {
            Button {
                activeSheet = .colorPicker
            } label: {
                HStack {
                    if selectedColor != nil {
                        Circle()
                            .fill(selectedColor ?? .red)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle().stroke(Color.black, lineWidth: 1)
                            )
                    }
                    Text(selectedColor != nil ? "Color seleccionado" : "Selecciona color")
                }
            }
        }
        
        Section("Tipo de icono") {
            Picker("Selecciona tipo", selection: $selectionMode) {
                ForEach(SelectionMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode as SelectionMode)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    @ViewBuilder
    var iconSelectionSection: some View {
        switch selectionMode {
        case .emoji:
            // MARK: - Emoji Buttons
            Section(header: Text("Emojis")) {
                VStack(spacing: 12) {
                    emojiButton(title: "Emoji 1", emoji: selectedIconOne.emoji, id: 1)
                    emojiButton(title: "Emoji 2", emoji: selectedIconTwo.emoji, id: 2)
                    emojiButton(title: "Emoji 3", emoji: selectedIconThree.emoji, id: 3)
                }
            }
        case .image:
            // MARK: - Image Picker (if needed)
            UserImagesPickerView(
                viewModel: userImageVM
            )
        }
    }
    
    @ViewBuilder
    var prioritySection: some View {
        // MARK: - Priority Picker
        Section(header: Text("Prioridad")) {
            Picker("Prioridad", selection: $selectedPriority) {
                Text("Selecciona prioridad").tag(Priority?.none)
                Text("Alta \(Priority.high.emoji)").tag(Priority?.some(.high))
                Text("Media \(Priority.medium.emoji)").tag(Priority?.some(.medium))
                Text("Baja \(Priority.low.emoji)").tag(Priority?.some(.low))
                Text("Mixta \(Priority.mixed.emoji)").tag(Priority?.some(.mixed))
            }
            .pickerStyle(.menu)
        }
    }
    
    
    
    var body: some View {
        NavigationStack {
            let noun = isSubCategory ? "subcategoría" : "categoría"
            Form {
                nameAndIcon
                iconSelectionSection
                prioritySection

                // MARK: - Save Button
                Section {
                    Button {
                        if isCategoryValid {
                            let selectedColorName = CategoryDetailWrapperView.allColorsMap[selectedColor ?? Color.red]
                            let oldCategoryName = category.name
                         category.name = name
                         category.priority = selectedPriority ?? .medium
                         category.colorAssetName = selectedColorName ?? "red"

                            switch(selectionMode) {
                            case .emoji:
                             category.icon = UserImageSlot(
                                    emojis: [
                                        selectedIconOne,
                                        selectedIconTwo,
                                        selectedIconThree
                                    ]
                                )
                            case .image:
                             category.icon = UserImageSlot(
                                    image: userImageVM.image
                                )
                            }

                            upsertCategory(
                                categoryName: oldCategoryName,
                                parent: parent,
                                category: category
                            )


                            dismiss()
                        } else {
                            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                alertMessage = "¡Falta nombre!"
                            } else if selectedColor == nil {
                                alertMessage = "¡Falta color!"
                            } else if selectionMode == .emoji && selectedIconOne.emoji.isEmpty && selectedIconTwo.emoji.isEmpty && selectedIconThree.emoji.isEmpty {
                                alertMessage = "¡Hace falta al menos un emoji!"
                            } else if selectionMode == .image {
                                alertMessage = "¡Hace falta una imagen!"
                            } else if selectedPriority == nil {
                                alertMessage = "¡Falta prioridad!"
                            }
                            showAlert = true
                        }
                    } label: {
                        Label("Guardar categoría", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                    }
                    .alert(alertMessage, isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    }
                }
                
                Section(header: Text("Subcategorías")) {
                    if category.subCategories.isEmpty {
                            Text("No hay subcategorías")

                            Button {
                                newSub = Category(
                                    name: "",
                                    icon: UserImageSlot(image: nil),
                                    priority: .medium,
                                    isSubcategory: true
                                )
                            } label: {
                                Label("Añadir subcategoría", systemImage: "plus.circle")
                            }
                    } else {
                        ForEach(Array(category.subCategories.values), id: \.id) { sub in
                            NavigationLink {
                                CategoryDetailWrapperView(
                                    viewModel: viewModel,
                                    category: sub,
                                    userImageVM: userImageVM,
                                    parent: parent ?? category,
                                    isSubcategory: true
                                )
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(sub.color)
                                        .frame(width: 28, height: 28)
                                        .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 1))
                                    Text(sub.name)
                                    Spacer()
                                    Text(sub.priority.emoji)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 6)
                      }
                        }.navigationDestination(item: $newSub) { sub in
                            CategoryDetailWrapperView(
                                viewModel: viewModel,
                                category: sub,
                                userImageVM: userImageVM,
                                parent: parent ?? category,
                                isSubcategory: true
                            )
                        }


                    }
                }

            }
            .navigationTitle( (initialName == "" ? "Nueva " : "Editar ") + noun )
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .colorPicker:
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 48))], spacing: 12) {
                        ForEach(CategoryDetailWrapperView.allColors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(Color.black, lineWidth: 1))
                                .onTapGesture {
                                    selectedColor = color
                                    activeSheet = nil
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                }
            case .emoji(let id):
                switch id {
                case 1: EmojiSearchView(selectedIcon: $selectedIconOne)
                case 2: EmojiSearchView(selectedIcon: $selectedIconTwo)
                case 3: EmojiSearchView(selectedIcon: $selectedIconThree)
                default: EmojiSearchView(selectedIcon: $selectedIconThree)
                }
            }
        }
    }

    // MARK: - Helper: Emoji Button
    @ViewBuilder
    private func emojiButton(title: String, emoji: String, id: Int) -> some View {
        Button {
            activeSheet = .emoji(id)
        } label: {
            HStack {
                Text(title)
                Text(emoji.isEmpty ? "—" : emoji)
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func upsertCategory(categoryName: String, parent: Category?, category: Category) {
                                    if viewModel.categoryExists(name: categoryName) == false {
                                viewModel.addCategory(category: category)
                            }else {
                                // Actualizar categoría existente
                                viewModel.updateCategory(oldName: categoryName, newCategory: category)
                            }
        if let parent = parent {
            viewModel.addSubCategory(category: parent, subCategory: category)
        } 

    }

    enum ActiveSheet: Identifiable {
        case colorPicker
        case emoji(Int)
        var id: String {
            switch self {
            case .colorPicker: return "colorPicker"
            case .emoji(let id): return "emoji\(id)"
            }
        }
    }
}
