import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyNotesViewModel

    @State private var title = ""
    @State private var content = ""

    var body: some View {
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
        .navigationTitle("Nueva Nota") // Esto sí funciona en macOS
        .toolbar {
            // En macOS, el toolbar se muestra en la parte superior de la ventana
            ToolbarItemGroup {
                Button("Cancelar") {
                    dismiss()
                }
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
