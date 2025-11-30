import SwiftUI

struct HabitCategoryView: View {
    // Local state for creating a category
    @State private var name: String = ""
    @State private var selectedIconOne: String = ""
    @State private var selectedIconTwo: String = ""
    @State private var selectedIconThree: String = ""

    // Wrapper to make a Binding<String> identifiable for the sheet
    struct EmojiBindingWrapper: Identifiable {
        let id = UUID()
        var binding: Binding<String>
    }

    @State private var activeEmoji: EmojiBindingWrapper? = nil

    @State private var selectedPriority: Priority = .medium
    @State private var selectedFrequency: Frequency = .weekly
    @State private var progress: Double = 0.0

    @StateObject private var loader = EmojiLoader()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nombre")) {
                    TextField("Nombre de la categoría", text: $name)
                }

                Section(header: Text("Emojis:")) {
                    VStack() {
                        Button {
                            activeEmoji = EmojiBindingWrapper(binding: $selectedIconOne)
                        } label: {
                            HStack {
                                Text("Emoji 1")
                                Text(selectedIconOne.isEmpty ? "" : selectedIconOne)
                            }.frame(alignment: .leading)                       }

                        Button {
                            activeEmoji = EmojiBindingWrapper(binding: $selectedIconTwo)
                        } label: {
                            HStack {
                                Text("Emoji 2")
                                Text(selectedIconTwo.isEmpty ? "" : selectedIconTwo)
                            }.frame(alignment: .leading)                        }

                        Button {
                            activeEmoji = EmojiBindingWrapper(binding: $selectedIconThree)
                        } label: {
                            HStack {
                                Text("Emoji 3")
                                Text(selectedIconThree.isEmpty ? "" : selectedIconThree)
                            }.frame(alignment: .leading)                        }
                    }
                }

                Section(header: Text("Prioridad")) {
                    Picker("Prioridad", selection: $selectedPriority) {
                        Text("\(Priority.high.emoji) Alta").tag(Priority.high)
                        Text("\(Priority.medium.emoji) Media").tag(Priority.medium)
                        Text("\(Priority.low.emoji) Baja").tag(Priority.low)
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Frecuencia")) {
                    Picker("Frecuencia", selection: $selectedFrequency) {
                        Text("Diaria \(Frequency.daily.emoji)").tag(Frequency.daily)
                        Text("Semanal \(Frequency.weekly.emoji)").tag(Frequency.weekly)
                        Text("Mensual \(Frequency.monthly.emoji)").tag(Frequency.monthly)
                        Text("Anual \(Frequency.annual.emoji)").tag(Frequency.annual)
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Button {
                        // Save action
                    } label: {
                        Label("Guardar categoría", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Nueva categoría")
        }
        // Sheet attached once to the Form (or outer VStack)
        .sheet(item: $activeEmoji) { wrapper in
            EmojiSearchView(selectedIcon: wrapper.binding)
        }
    }

    // MARK: - Icon Picker Grid

    private struct IconPickerGrid: View {
        let icons: [String]
        @Binding var selectedIcon: String

        // 5 columns grid
        private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

        var body: some View {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(icons, id: \.self) { icon in
                    Button {
                        selectedIcon = icon
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.12))
                            Image(systemName: icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(selectedIcon == icon ? Color.accentColor : Color.primary)
                                .padding(10)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedIcon == icon ? Color.accentColor : Color.gray.opacity(0.25), lineWidth: selectedIcon == icon ? 2 : 1)
                    )
                    .accessibilityLabel(Text(icon))
                    .accessibilityAddTraits(selectedIcon == icon ? .isSelected : [])
                }
            }
        }
    }
}
