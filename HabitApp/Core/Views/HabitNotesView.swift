import SwiftUI
import SwiftData

struct HabitNotesView: View {
    let habit: Habit
    let currentDate: Date
    let storageProvider: StorageProvider
    @Query private var allNotes: [DailyNote]
    
    @State private var showingAddNote = false
    @StateObject private var notesViewModel: DailyNotesViewModel
    @Environment(\.dismiss) private var dismiss
    private let calendar = Calendar.current

    init(habit: Habit, currentDate: Date, storageProvider: StorageProvider) {
        self.habit = habit
        self.currentDate = currentDate
        self.storageProvider = storageProvider
        _notesViewModel = StateObject(wrappedValue: DailyNotesViewModel(storageProvider: storageProvider))
    }

    var body: some View {
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
}

// MARK: - iOS UI
#if os(iOS)
extension HabitNotesView {
    var iosBody: some View {
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
}
#endif

// MARK: - macOS UI
#if os(macOS)
extension HabitNotesView {
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
                
                Text("Notas - \(habit.title)")
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
            if habitNotes.isEmpty {
                ContentUnavailableView(
                    "Sin notas",
                    systemImage: "note.text",
                    description: Text("No hay notas para \(habit.title) en esta fecha")
                )
            } else {
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
                        .contextMenu {
                            Button("Eliminar", role: .destructive) {
                                notesViewModel.deleteNote(note)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(habit: habit, noteDate: currentDate)
        }
    .frame(minWidth: 350, minHeight: 280)  
  }
}
#endif

// MARK: - Helpers
extension HabitNotesView {

    private var habitNotes: [DailyNote] {
        let startOfDay = calendar.startOfDay(for: currentDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return allNotes.filter { note in
            note.habitId == habit.id &&
            note.date >= startOfDay &&
            note.date < endOfDay
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        let sorted = habitNotes.sorted { $0.date > $1.date }
        for i in offsets { 
            notesViewModel.deleteNote(sorted[i])
        }
    }
}
