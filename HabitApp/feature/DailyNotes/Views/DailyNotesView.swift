import SwiftUI
import SwiftData

struct DailyNotesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DailyNotesViewModel?
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let viewModel = viewModel {
                    DatePicker("Fecha", selection: Binding(
                        get: { viewModel.selectedDate },
                        set: { viewModel.changeDate(to: $0) }
                    ), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    
                    if viewModel.notes.isEmpty {
                        ContentUnavailableView(
                            "Sin notas",
                            systemImage: "note.text",
                            description: Text("No hay notas para esta fecha")
                        )
                    } else {
                        List {
                            ForEach(viewModel.notes, id: \.id) { note in
                                NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                                    NoteRowView(note: note)
                                }
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    viewModel.deleteNote(viewModel.notes[index])
                                }
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Notas Diarias")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                if let viewModel = viewModel {
                    AddNoteView(viewModel: viewModel)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DailyNotesViewModel(modelContext: modelContext)
            }
        }
    }
}