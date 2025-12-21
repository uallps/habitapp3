import SwiftUI

struct CategoryDetailWrapperView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CategoryListViewModel
    @State var categorySet: CategorySet
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
        guard selectedFrequency != nil else { return false }
        return true
    }

    // MARK: - Category State
    @State private var name: String = ""
    @State private var selectedIconOne: Emoji = Emoji(emoji: "", name: "", id: "")
    @State private var selectedIconTwo: Emoji = Emoji(emoji: "", name: "", id: "")
    @State private var selectedIconThree: Emoji = Emoji(emoji: "", name: "", id: "")

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
    @State private var selectedFrequency: Frequency? = nil
    @State private var selectedColor: Color? = nil

    enum SelectionMode: String, CaseIterable, Identifiable {
        case emoji = "Emoji"
        case image = "Imagen"
        var id: String { rawValue }
    }

    @State private var selectionMode: SelectionMode = .emoji

    var body: some View {
        NavigationStack {
            Form {
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

                // MARK: - Priority Picker
                Section(header: Text("Prioridad")) {
                    Picker("Prioridad", selection: $selectedPriority) {
                        Text("Selecciona prioridad").tag(Priority?.none)
                        Text("\(Priority.high.emoji)").tag(Priority?.some(.high))
                        Text("\(Priority.medium.emoji)").tag(Priority?.some(.medium))
                        Text("\(Priority.low.emoji)").tag(Priority?.some(.low))
                    }
                    .pickerStyle(.menu)
                }

                // MARK: - Frequency Picker
                Section(header: Text("Frecuencia")) {
                    Picker("Frecuencia", selection: $selectedFrequency) {
                        Text("Selecciona frecuencia").tag(Frequency?.none)
                        Text("\(Frequency.daily.emoji)").tag(Frequency?.some(.daily))
                        Text("\(Frequency.weekly.emoji)").tag(Frequency?.some(.weekly))
                        Text("\(Frequency.monthly.emoji)").tag(Frequency?.some(.monthly))
                        Text("\(Frequency.annual.emoji)").tag(Frequency?.some(.annual))
                    }
                    .pickerStyle(.menu)
                }

                // MARK: - Save Button
                Section {
                    Button {
                        if isCategoryValid {
                            let selectedColorName = CategoryDetailWrapperView.allColorsMap[selectedColor ?? Color.red]
                            categorySet.name = name
                            categorySet.priority = selectedPriority ?? .medium
                            categorySet.frequency = selectedFrequency ?? .daily
                            categorySet.colorAssetName = selectedColorName ?? "red"

                            switch(selectionMode) {
                            case .emoji:
                                categorySet.icon = UserImageSlot(
                                    emojis: [
                                        selectedIconOne,
                                        selectedIconTwo,
                                        selectedIconThree
                                    ]
                                )
                            case .image:
                                categorySet.icon = UserImageSlot(
                                    image: userImageVM.image
                                )
                            }

                            viewModel.addCategory(category: categorySet)
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
                            } else if selectedFrequency == nil {
                                alertMessage = "¡Falta frecuencia!"
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
            }
            .navigationTitle("Nueva categoría")
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
