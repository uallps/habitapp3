import SwiftUI
import SwiftData

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let viewModel: DailyNotesViewModel?
    let habit: Habit?
    let noteDate: Date

    @State private var title = ""
    @State private var content = ""
    
    init(viewModel: DailyNotesViewModel? = nil, habit: Habit? = nil, noteDate: Date = Date()) {
        self.viewModel = viewModel
        self.habit = habit
        self.noteDate = noteDate
    }

    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
}

// MARK: - iOS UI
#if os(iOS)
extension AddNoteView {
    var iosBody: some View {
        NavigationStack {
            Form {
                Section("Título") {
                    TextField("Título de la nota", text: $title)
                }

                Section("Contenido") {
                    TextEditor(text: $content)
                        .frame(minHeight: 180)
                }
            }
            .navigationTitle("Nueva Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveNote()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension AddNoteView {
    var macBody: some View {
        VStack {
            Form {
                Section("Título") {
                    TextField("Título de la nota", text: $title)
                }

                Section("Contenido") {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
            }
        }
        .navigationTitle("Nueva Nota")
        .toolbar {
            ToolbarItemGroup {
                Button("Cancelar") { dismiss() }
                Button("Guardar") {
                    saveNote()
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
        }
        .frame(minWidth: 400, minHeight: 300)
        .padding()
    }
}
#endif

// MARK: - Funciones comunes
extension AddNoteView {
    private func saveNote() {
        if let viewModel = viewModel {
            // Usar la fecha pasada directamente al viewModel
            let calendar = Calendar.current
            let normalizedDate = calendar.startOfDay(for: noteDate)
            viewModel.selectedDate = normalizedDate
            viewModel.addNote(title: title, content: content)
        } else {
            // Insertar nota directamente en el contexto
            let calendar = Calendar.current
            let normalizedDate = calendar.startOfDay(for: noteDate)
            let note = DailyNote(title: title, content: content, date: normalizedDate)
            note.habit = habit
            modelContext.insert(note)
            try? modelContext.save()
        }
    }
}
