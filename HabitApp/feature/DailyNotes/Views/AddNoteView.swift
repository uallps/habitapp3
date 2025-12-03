import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let viewModel: DailyNotesViewModel?
    let habit: Habit?

    @State private var title = ""
    @State private var content = ""
    
    init(viewModel: DailyNotesViewModel? = nil, habit: Habit? = nil) {
        self.viewModel = viewModel
        self.habit = habit
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
                        if let viewModel = viewModel {
                            viewModel.addNote(title: title, content: content)
                        } else {
                            let note = DailyNote(title: title, content: content, habit: habit)
                            modelContext.insert(note)
                            try? modelContext.save()
                        }
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
                    if let viewModel = viewModel {
                        viewModel.addNote(title: title, content: content)
                    } else {
                        let note = DailyNote(title: title, content: content, habit: habit)
                        modelContext.insert(note)
                        try? modelContext.save()
                    }
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

