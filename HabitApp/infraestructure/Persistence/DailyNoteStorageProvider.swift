protocol DailyNoteStorageProvider {
    func loadNotes() async throws -> [DailyNote]
    func saveNotes(notes: [DailyNote]) async throws
    func loadNotesForHabit(habitId: UUID) async throws -> [DailyNote]
    func loadNotesForDate(date: Date) async throws -> [DailyNote]
}