import SwiftUI

struct CategoryDetailWrapperView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CategoryListViewModel
    @State var categorySet: CategorySet
    
    // MARK: - Category State
    @State private var name: String = ""
    @State private var selectedIconOne: String = ""
    @State private var selectedIconTwo: String = ""
    @State private var selectedIconThree: String = ""

    @State private var selectedPriority: Priority = .medium
    @State private var selectedFrequency: Frequency = .weekly
    
    enum SelectionMode: String, CaseIterable, Identifiable {

          case emoji = "Emoji"

          case image = "Imagen"

          var id: String { rawValue }

      }
    
    @State private var selectionMode: SelectionMode = .emoji

    // MARK: - Emoji Picker Sheet
    struct ActiveEmoji: Identifiable {
        let id: Int
    }
    @State private var activeEmoji: ActiveEmoji? = nil

    // Emoji loader if needed
    @StateObject private var loader = EmojiLoader()
    
    var body: some View {
            NavigationStack {
                Form {
                    // MARK: - Name
                    Section(header: Text("Nombre")) {
                        TextField("Nombre de la categoría", text: $name)
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
                                emojiButton(title: "Emoji 1", emoji: selectedIconOne, id: 1)
                                emojiButton(title: "Emoji 2", emoji: selectedIconTwo, id: 2)
                                emojiButton(title: "Emoji 3", emoji: selectedIconThree, id: 3)
                            }
                        }
                    case .image:
                        // MARK: - Image Picker (if needed)
                        UserImagesPickerView()
                    }

                    // MARK: - Priority Picker
                    Section(header: Text("Prioridad")) {
                        Picker("Prioridad", selection: $selectedPriority) {
                            Text("\(Priority.high.emoji) Alta").tag(Priority.high)
                            Text("\(Priority.medium.emoji) Media").tag(Priority.medium)
                            Text("\(Priority.low.emoji) Baja").tag(Priority.low)
                        }
                        .pickerStyle(.segmented)
                    }

                    // MARK: - Frequency Picker
                    Section(header: Text("Frecuencia")) {
                        Picker("Frecuencia", selection: $selectedFrequency) {
                            Text("Diaria \(Frequency.daily.emoji)").tag(Frequency.daily)
                            Text("Semanal \(Frequency.weekly.emoji)").tag(Frequency.weekly)
                            Text("Mensual \(Frequency.monthly.emoji)").tag(Frequency.monthly)
                            Text("Anual \(Frequency.annual.emoji)").tag(Frequency.annual)
                        }
                        .pickerStyle(.menu)
                    }

                    // MARK: - Save Button
                    Section {
                        Button {
                            categorySet.name = name
                            categorySet.priority = selectedPriority
                            categorySet.frequency = selectedFrequency
                            viewModel.addCategory(category: categorySet)
                            dismiss()
                        } label: {
                            Label("Guardar categoría", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                        }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .navigationTitle("Nueva categoría")
            }
            // MARK: - Emoji Sheet (single sheet for all buttons)
            .sheet(item: $activeEmoji) { wrapper in
                switch wrapper.id {
                case 1: EmojiSearchView(selectedIcon: $selectedIconOne)
                case 2: EmojiSearchView(selectedIcon: $selectedIconTwo)
                default: EmojiSearchView(selectedIcon: $selectedIconThree)
                }
            }
        }

        // MARK: - Helper: Emoji Button
        @ViewBuilder
        private func emojiButton(title: String, emoji: String, id: Int) -> some View {
            Button {
                activeEmoji = ActiveEmoji(id: id)
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
