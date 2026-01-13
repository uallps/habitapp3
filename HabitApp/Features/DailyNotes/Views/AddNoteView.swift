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
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Nueva Nota")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Cancelar") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Guardar") {
                    saveNote()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(title.isEmpty)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // Form
            Form {
                Section("Título") {
                    TextField("Título de la nota", text: $title)
                }

                Section("Contenido") {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
            }
            .formStyle(.grouped)
        }
        .frame(minWidth: 500, minHeight: 400)
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
            note.habitId = habit?.id
            modelContext.insert(note)
            try? modelContext.save()
            
            // Programar notificación si la nota es para una fecha futura
            let today = calendar.startOfDay(for: Date())
            if normalizedDate > today {
                let notificationTitle = habit != nil ? "Hábito: \(habit!.title) - \(title)" : "Nota: \(title)"
                HabitDataObserverManager.shared.notify(
                    taskId: note.id,
                    title: notificationTitle,
                    date: normalizedDate
                )
            }
        }
    }
}
