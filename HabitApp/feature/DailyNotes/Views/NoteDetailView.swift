import SwiftUI

struct NoteDetailView: View {
    let note: DailyNote
    let viewModel: DailyNotesViewModel
    
    @State private var title: String
    @State private var content: String
    @State private var isEditing = false
    
    init(note: DailyNote, viewModel: DailyNotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        self._title = State(initialValue: note.title)
        self._content = State(initialValue: note.content)
    }
    
    var body: some View {
        ScrollView {
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
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Guardar" : "Editar") {
                    if isEditing {
                        viewModel.updateNote(note, title: title, content: content)
                    }
                    isEditing.toggle()
                }
            }
        }
    }
}