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
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
}

#if os(iOS)
extension NoteDetailView {
    var iosBody: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        contentView
                            .padding(20)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Detalle de Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    editSaveButton
                    deleteButton
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
        }
    }
}
#endif

#if os(macOS)
extension NoteDetailView {
    var macBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            contentView
                .padding(20)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(12)
        }
        .padding()
        .navigationTitle("Detalle de Nota")
        .toolbar {
            ToolbarItemGroup {
                editSaveButton
                deleteButton
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
    }
}
#endif

// MARK: - Common Views
extension NoteDetailView {
    private var contentView: some View {
        Group {
            if isEditing {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Título", text: $title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .textFieldStyle(.roundedBorder)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text(note.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(note.content)
                        .font(.body)
                        .lineSpacing(1.2)
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Creado: \(note.createdAt, style: .date) a las \(note.createdAt, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if note.updatedAt != note.createdAt {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Actualizado: \(note.updatedAt, style: .date) a las \(note.updatedAt, style: .time)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
            
            Spacer()
        }
    }
    
    private var editSaveButton: some View {
        #if os(iOS)
        Group {
            if isEditing {
                Button("Guardar") {
                    viewModel.updateNote(note, title: title, content: content)
                    dismiss()
                    isEditing.toggle()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Editar") {
                    isEditing.toggle()
                }
                .buttonStyle(.bordered)
            }
        }
        #else
        Button(isEditing ? "Guardar" : "Editar") {
            if isEditing {
                viewModel.updateNote(note, title: title, content: content)
                dismiss()
            }
            isEditing.toggle()
        }
        .buttonStyle(.bordered)
        #endif
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteAlert = true
        } label: {
            Image(systemName: "trash")
        }
    }
}
