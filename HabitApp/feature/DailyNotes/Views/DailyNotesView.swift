import SwiftUI
import SwiftData

struct DailyNotesView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: DailyNotesViewModel
    @State private var showingAddNote = false
    
    init(modelContext: ModelContext? = nil) {
        #if os(iOS)
        let context = ModelContext(try! ModelContainer(for: DailyNote.self))
        _viewModel = StateObject(wrappedValue: DailyNotesViewModel(modelContext: context))
        #else
        if let modelContext {
            _viewModel = StateObject(wrappedValue: DailyNotesViewModel(modelContext: modelContext))
        } else {
            let container = try! ModelContainer(for: DailyNote.self)
            let context = ModelContext(container)
            _viewModel = StateObject(wrappedValue: DailyNotesViewModel(modelContext: context))
        }
        #endif
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
            VStack(spacing: 12) {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.selectedDate },
                        set: { viewModel.changeDate(to: $0) }
                    ),
                    in: Date()...Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                if viewModel.notes.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Sin notas")
                            .font(.headline)
                        Text("No hay notas para esta fecha")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                } else {
                    List {
                        ForEach(viewModel.notes, id: \.id) { note in
                            NavigationLink {
                                NoteDetailView(note: note, viewModel: viewModel)
                            } label: {
                                NoteRowView(note: note)
                                    .padding(.vertical, 6)
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
            .navigationTitle("Notas Diarias")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel, noteDate: viewModel.selectedDate)
            }
            .padding(.vertical)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
}
#endif

// MARK: - macOS
#if os(macOS)
extension DailyNotesView {
    var macBody: some View {
        VStack(spacing: 16) {
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
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            
            if viewModel.notes.isEmpty {
                ContentUnavailableView(
                    "Sin notas",
                    systemImage: "note.text",
                    description: Text("No hay notas para esta fecha")
                )
            } else {
                List {
                    ForEach(viewModel.notes, id: \.id) { note in
                        NavigationLink {
                            NoteDetailView(note: note, viewModel: viewModel)
                        } label: {
                            NoteRowView(note: note)
                        }
                        .contextMenu {
                            Button("Eliminar", role: .destructive) {
                                viewModel.deleteNote(note)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteNote(viewModel.notes[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("Notas Diarias")
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddNote = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(viewModel: viewModel, noteDate: viewModel.selectedDate)
        }
        .frame(minWidth: 500, minHeight: 400)
        .padding()
    }
}
#endif
