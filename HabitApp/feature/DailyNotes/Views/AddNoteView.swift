import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyNotesViewModel

    @State private var title = ""
    @State private var content = ""

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
                        viewModel.addNote(title: title, content: content)
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
                    viewModel.addNote(title: title, content: content)
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

