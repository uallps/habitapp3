import SwiftUI
import SwiftData

struct DailyNotesView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: DailyNotesViewModel
    @State private var showingAddNote = false
    
    init(modelContext: ModelContext? = nil) {
        if let modelContext {
            _viewModel = StateObject(wrappedValue: DailyNotesViewModel(modelContext: modelContext))
        } else {
            do {
                let container = try ModelContainer(for: DailyNote.self)
                let context = ModelContext(container)
                _viewModel = StateObject(wrappedValue: DailyNotesViewModel(modelContext: context))
            } catch {
                fatalError(" No se pudo crear el contenedor de SwiftData: \(error)")
            }
        }
    }

    var body: some View {
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
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
            
            if viewModel.notes.isEmpty {
                ContentUnavailableView(
                    "Sin notas",
                    systemImage: "note.text",
                    description: Text("No hay notas para esta fecha")
                )
                .padding()
            } else {
                List {
                    ForEach(viewModel.notes, id: \.id) { note in
                        NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                            NoteRowView(note: note)
                        }
                        .listRowInsets(EdgeInsets()) // Elimina el padding extra
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

                .dailyNotesListStyle() // <- estilo de lista
            }
        }
        .dailyNotesStyle() // <- aplica estilo al VStack principal
        .navigationTitle("Notas Diarias")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    showingAddNote = true
                } label: {
                    Image(systemName: "plus")
                }
                .dailyNotesToolbarButton() // <- botón estilizado
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(viewModel: viewModel)
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}
