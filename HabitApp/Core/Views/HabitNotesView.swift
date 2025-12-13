import SwiftUI
import SwiftData

struct HabitNotesView: View {
    let habit: Habit
    @Environment(\.modelContext) private var modelContext
    @Query private var allNotes: [DailyNote]
    
    @State private var showingAddNote = false
    @StateObject private var notesViewModel: DailyNotesViewModel

    init(habit: Habit, modelContext: ModelContext) {
        self.habit = habit
        _notesViewModel = StateObject(wrappedValue: DailyNotesViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(habitNotes.sorted { $0.date > $1.date }) { note in
                    NavigationLink {
                        NoteDetailView(note: note, viewModel: notesViewModel)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                if !note.content.isEmpty {
                                    Text(note.content)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            Spacer()
                            Text(note.date, format: .dateTime.day().month())
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.inset)
            #endif
            .navigationTitle("Notas - \(habit.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                #if os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                #else
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingAddNote = true } label: {
                        Image(systemName: "plus")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(habit: habit)
            }
        }
    }

    private var habitNotes: [DailyNote] {
        allNotes.filter { $0.habit?.id == habit.id }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        let sorted = habitNotes.sorted { $0.date > $1.date }
        for i in offsets { modelContext.delete(sorted[i]) }
        try? modelContext.save()
    }
}
