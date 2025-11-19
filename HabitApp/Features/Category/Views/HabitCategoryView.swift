import SwiftUI

struct HabitCategoryView: View {
    // Local state for creating a category
    @State private var name: String = ""
    @State private var selectedIcon: String = "folder"
    @State private var selectedPriority: Priority = .medium
    @State private var selectedFrequency: Frequency = .weekly
    @State private var progress: Double = 0.0
    
    // A simple pool of SF Symbols to choose from
    private let iconOptions: [String] = [
        "folder", "bookmark", "star", "heart", "leaf", "flame",
        "bolt", "sun.max", "moon", "cloud", "figure.walk",
        "figure.run", "bicycle", "book", "music.note", "paintbrush",
        "pencil", "clock", "calendar", "checkmark.seal"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Nombre")) {
                    TextField("Nombre de la categoría", text: $name)
                }
                
                Section(header: Text("Icono")) {
                    IconPickerGrid(
                        icons: iconOptions,
                        selectedIcon: $selectedIcon
                    )
                    .padding(.vertical, 4)
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
                
                Section(header: Text("Progreso")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            ProgressView(value: progress / 100.0)
                                .frame(maxWidth: .infinity)
                            Text("\(Int(progress))%")
                                .monospacedDigit()
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $progress, in: 0...100, step: 1) {
                            Text("Progreso")
                        } minimumValueLabel: {
                            Text("0%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } maximumValueLabel: {
                            Text("100%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button {
                    } label: {
                        Label("Guardar categoría", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Nueva categoría")
        }
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
