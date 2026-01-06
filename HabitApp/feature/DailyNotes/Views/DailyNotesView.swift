import SwiftUI
import SwiftData

struct DailyNotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appConfig: AppConfig
    @StateObject private var viewModel: DailyNotesViewModel
    @State private var showingAddNote = false
    
    private let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        _viewModel = StateObject(wrappedValue: DailyNotesViewModel(storageProvider: storageProvider))
    }
    
    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
}

// MARK: - iOS
#if os(iOS)
extension DailyNotesView {
    var iosBody: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Notas Diarias")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button {
                            showingAddNote = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    DatePicker(
                        "Fecha",
                        selection: Binding(
                            get: { viewModel.selectedDate },
                            set: { viewModel.changeDate(to: $0) }
                        ),
                        in: Date()...Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                }
                .padding(16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.05),
                            Color.purple.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                Divider()
                
                // Contenido
                if viewModel.notes.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "note.text")
                            .font(.system(size: 56))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Sin notas")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Crea tu primera nota tocando el botón +")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.notes, id: \.id) { note in
                            NavigationLink {
                                NoteDetailView(note: note, viewModel: viewModel)
                            } label: {
                                NoteRowView(note: note)
                                    .padding(.vertical, 8)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteNote(viewModel.notes[index])
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel, noteDate: viewModel.selectedDate)
            }
        }
    }
}
#endif

// MARK: - macOS
#if os(macOS)
extension DailyNotesView {
    var macBody: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Label("Cerrar", systemImage: "xmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Cerrar ventana")
                
                Text("Notas Diarias")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading, 8)
                
                Spacer()
                
                Button {
                    showingAddNote = true
                } label: {
                    Label("Nueva Nota", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            // Content
            VStack(spacing: 12) {
                DatePicker(
                    "Fecha",
                    selection: Binding(
                        get: { viewModel.selectedDate },
                        set: { viewModel.changeDate(to: $0) }
                    ),
                    in: Date()...Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.controlBackgroundColor))
                )
                .padding()
                
                if viewModel.notes.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "note.text")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Sin notas")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Crea tu primera nota haciendo clic en Nueva Nota")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(viewModel.notes, id: \.id) { note in
                            NavigationLink {
                                NoteDetailView(note: note, viewModel: viewModel)
                            } label: {
                                NoteRowView(note: note)
                                    .padding(.vertical, 4)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteNote(viewModel.notes[index])
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .padding(.horizontal)
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(viewModel: viewModel, noteDate: viewModel.selectedDate)
        }
    }
}
#endif
