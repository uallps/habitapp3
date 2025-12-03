import SwiftUI
import SwiftData

struct HabitNotesView: View {
    let habit: Habit
    @Query private var allNotes: [DailyNote]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddNote = false
    
    private var habitNotes: [DailyNote] {
        allNotes.filter { $0.habit?.id == habit.id }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(habitNotes.sorted { $0.date > $1.date }) { note in
                    NavigationLink {
                        NoteDetailView(note: note)
                    } label: {
                        NoteRowView(note: note)
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Notas - \(habit.title)")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(habit: habit)
            }
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        let sortedNotes = habitNotes.sorted { $0.date > $1.date }
        for index in offsets {
            modelContext.delete(sortedNotes[index])
        }
        try? modelContext.save()
    }
}