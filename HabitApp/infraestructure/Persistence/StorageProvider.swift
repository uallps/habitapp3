import Foundation

protocol StorageProvider {
    //IF HABIT
    func loadHabits() async throws -> [Habit]
    func saveHabits(habits: [Habit]) async throws
    func addHabit(habit: Habit) async throws
    //func updateHabit(habit: Habit) async throws
    func deleteHabit(habit: Habit) async throws
    func getHabit(id: UUID) async throws-> Habit?
    //END HABIT
    
    //DEV ONLY METHOD
    func resetStorage()
    //END DEV ONLY METHOD
    //IF GOAL
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) async throws
    func deleteGoal(_ goal: Goal) async throws
    //END GOAL
    //IF DAILYNOTES
    func loadNotes(calendar: Calendar, startOfDay: Date, endOfDay: Date, selectedDate: Date) async throws -> [DailyNote]
    func addNote(title: String, content: String, selectedDate: Date, noteDate: Date) async throws -> DailyNote
    //func updateNote(_ note: DailyNote, title: String, content: String) async throws
    //func saveAndGoToNoteDate(_ note: DailyNote, title: String, content: String) async throws
    func deleteNote(_ note: DailyNote) async throws
    //END DAILYNOTES
        
    func saveContext() async throws
}
