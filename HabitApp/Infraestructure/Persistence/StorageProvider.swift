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
    
    func resetStorage()
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) async throws    //END GOAL
    
    //IF STREAK
    func loadStreaksForHabit(habitId: UUID) async throws -> [Streak]
    func saveStreak(_ streak: Streak) async throws
    func savePendingChanges() async throws
    func updateStreak(_ streak: Streak) async throws
    //END IF
    
    func saveContext() async throws
}
