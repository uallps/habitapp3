import SwiftUI

struct CategoryDetailWrapperView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var categoryListVM: CategoryListViewModel
    @ObservedObject var categoryDetailWrapperViewVM = CategoryDetailWrapperView()
    @ObservedObject var userImageVM: UserImagesViewModel
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var activeSheet: ActiveSheet?
    @State private var selectionMode: SelectionMode = .emoji
    
    // Lógica para prevenir guardar la categoría si falta información
    private var isCategoryValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }

        guard selectedColor != nil else { return false }
        
        switch selectionMode {
        case .emoji:
            guard !selectedIconOne.isEmpty || !selectedIconTwo.isEmpty || !selectedIconThree.isEmpty else { return false }
        case .image:
            if userImageVM.image == nil {
                return false
            }
        }

        guard selectedPriority != nil else { return false }
        guard selectedFrequency != nil else { return false }
        
        return true
    }

    // Estado de la categoría que se está creando o editando
    @State private var name: String = ""
    @State private var selectedIconOne: String = ""
    @State private var selectedIconTwo: String = ""
    @State private var selectedIconThree: String = ""
    
    @State private var selectedPriority: Priority? = nil
    @State private var selectedFrequency: Frequency? = nil
    @State private var selectedColor: Color? = nil
    
    
    
    var body: some View {
            NavigationStack {
                Form {
                    Section(header: Text("Nombre")) {
                        TextField("Nombre de la categoría", text: $name)
                    }
                    
                    Section("Color") {
                        Button {
                            activeSheet = .colorPicker
                        }label: {
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
                        Section(header: Text("Emojis")) {
                            VStack(spacing: 12) {
                                emojiButton(title: "Emoji 1", emoji: selectedIconOne, id: 1)
                                emojiButton(title: "Emoji 2", emoji: selectedIconTwo, id: 2)
                                emojiButton(title: "Emoji 3", emoji: selectedIconThree, id: 3)
                            }
                        }
                    case .image:
                        UserImagesPickerView(
                            categoryListVM: userImageVM
                        )
                    }

                    Section(header: Text("Prioridad")) {
                        Picker("Prioridad", selection: $selectedPriority) {
                            Text("Selecciona prioridad").tag(Priority?.none)
                            Text("\(Priority.high.emoji) Alta").tag(Priority?.some(.high))
                            Text("\(Priority.medium.emoji) Media").tag(Priority?.some(.medium))
                            Text("\(Priority.low.emoji) Baja").tag(Priority?.some(.low))
                        }
                        .pickerStyle(.menu)
                    }

                    Section(header: Text("Frecuencia")) {
                        Picker("Frecuencia", selection: $selectedFrequency) {
                            Text("Selecciona frecuencia").tag(Frequency?.none)
                            Text("Diaria \(Frequency.daily.emoji)").tag(Frequency?.some(.daily))
                            Text("Semanal \(Frequency.weekly.emoji)").tag(Frequency?.some(.weekly))
                            Text("Mensual \(Frequency.monthly.emoji)").tag(Frequency?.some(.monthly))
                            Text("Anual \(Frequency.annual.emoji)").tag(Frequency?.some(.annual))
                        }
                        .pickerStyle(.menu)
                    }

                    Section {
                        Button {
                            
                            if isCategoryValid {
                                categorySet.name = name
                                categorySet.priority = Priority.medium
                                categorySet.frequency = Frequency.daily
                                categoryListVM.addCategory(category: categorySet)
                                dismiss()
                            }else {
                                if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    alertMessage = "¡Falta nombre!"
                                } else if selectedColor == nil {
                                    alertMessage = "¡Falta color!"
                                } else if selectionMode == .emoji && selectedIconOne.isEmpty && selectedIconTwo.isEmpty && selectedIconThree.isEmpty {
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
            }        .sheet(item: $activeSheet) { item in
    switch item {
    case .colorPicker:
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 48))], spacing: 12) {
                ForEach(allColors, id: \.self) { color in
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
}


