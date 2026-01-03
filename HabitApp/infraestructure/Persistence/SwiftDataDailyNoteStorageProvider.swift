import Foundation
import SwiftData

class SwiftDataDailyNoteStorageProvider: DailyNoteStorageProvider {
    
    private let context: ModelContext
    
    init() {
        guard let sharedContext = SwiftDataContext.shared else {
            fatalError("SwiftDataContext not initialized")
        }
        self.context = sharedContext
    }
    
    func loadNotes() async throws -> [DailyNote] {
        let descriptor = FetchDescriptor<DailyNote>()
        return try context.fetch(descriptor)
    }
    
    func saveNotes(notes: [DailyNote]) async throws {
        let existingNotes = try await loadNotes()
        let existingIds = Set(existingNotes.map { $0.id })
        let newIds = Set(notes.map { $0.id })
        
        for existingNote in existingNotes where !newIds.contains(existingNote.id) {
            context.delete(existingNote)
        }
        
        for note in notes {
            if !existingIds.contains(note.id) {
                context.insert(note)
            }
        }
        
        try context.save()
    }
    
    func loadNotesForHabit(habitId: UUID) async throws -> [DailyNote] {
        let descriptor = FetchDescriptor<DailyNote>(
            predicate: #Predicate<DailyNote> { note in
                note.habitId == habitId
            }
        )
        return try context.fetch(descriptor)
    }
    
    func loadNotesForDate(date: Date) async throws -> [DailyNote] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<DailyNote>(
            predicate: #Predicate<DailyNote> { note in
                note.date >= startOfDay && note.date < endOfDay
            }
        )
        return try context.fetch(descriptor)
    }
}