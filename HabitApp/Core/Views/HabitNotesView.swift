import SwiftUI
import SwiftData

struct HabitNotesView: View {
    let habit: Habit
    let currentDate: Date
    @Environment(\.modelContext) private var modelContext
    @Query private var allNotes: [DailyNote]
    
    @State private var showingAddNote = false
    @StateObject private var notesViewModel: DailyNotesViewModel
    private let calendar = Calendar.current

    init(habit: Habit, currentDate: Date, modelContext: ModelContext) {
        self.habit = habit
        self.currentDate = currentDate
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
            .listStyle(.insetGrouped)
            .navigationTitle("Notas - \(habit.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingAddNote = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(habit: habit, noteDate: currentDate)
            }
        }
    }

    private var habitNotes: [DailyNote] {
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return allNotes.filter { note in
            note.habit?.id == habit.id &&
            note.date >= startOfDay &&
            note.date < endOfDay
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        let sorted = habitNotes.sorted { $0.date > $1.date }
        for i in offsets { modelContext.delete(sorted[i]) }
        try? modelContext.save()
    }
}
