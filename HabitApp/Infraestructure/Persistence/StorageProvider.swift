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
    
    //IF ACHIEVEMENTS
    func loadAchievements() async throws -> [Achievement]
    func saveAchievement(_ achievement: Achievement) async throws
    func deleteAchievement(_ achievement: Achievement) async throws
    //END IF
    
    func saveContext() async throws
}
