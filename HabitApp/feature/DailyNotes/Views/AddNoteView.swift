import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: DailyNotesViewModel
    
    @State private var title = ""
    @State private var content = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Título") {
                    TextField("Título de la nota", text: $title)
                }
                
                Section("Contenido") {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Nueva Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
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