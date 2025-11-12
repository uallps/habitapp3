import SwiftUI

struct NoteDetailView: View {
    let note: DailyNote
    let viewModel: DailyNotesViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    
    init(note: DailyNote, viewModel: DailyNotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isEditing {
                TextField("Título", text: $title)
                    .font(.title2)
                    .textFieldStyle(.roundedBorder)
                
                TextEditor(text: $content)
                    .frame(minHeight: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                Text(note.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(note.content)
                    .font(.body)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Creado: \(note.createdAt, style: .date) a las \(note.createdAt, style: .time)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if note.updatedAt != note.createdAt {
                    Text("Actualizado: \(note.updatedAt, style: .date) a las \(note.updatedAt, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Detalle de Nota")
        .toolbar {
            ToolbarItemGroup {
                Button(isEditing ? "Guardar" : "Editar") {
                    if isEditing {
                        viewModel.updateNote(note, title: title, content: content)
                        dismiss()
                    }
                    isEditing.toggle()
                }
                
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("¿Eliminar nota?", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                viewModel.deleteNote(note)
                dismiss()
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}
