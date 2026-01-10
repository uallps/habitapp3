import Foundation

protocol StorageProvider {
    //IF HABIT
    func loadHabits() async throws -> [Habit]
    func saveHabits(habits: [Habit]) async throws
    func addHabit(habit: Habit) async throws
    //func updateHabit(habit: Habit) async throws
    func deleteHabit(habit: Habit) async throws
    func getHabit(id: UUID) async throws-> Habit
    //END HABIT
    
    //IF CATEGORY
    func loadCategories() async throws -> [Category]
    func addCategory(category: Category) async throws
    func addSubcategory(category: Category, subCategory: Category) async throws
    func removeCategory(category: Category) async throws
    func removeSubCategory(category: Category, subCategory: Category) async throws
    func categoryExists(id: UUID) async throws -> Bool
    func updateCategory(id: UUID, newCategory: Category) async throws
    func upsertCategoryOrSubcategory(parent: Category?, category: Category) async throws
    func addHabitToCategory(habit: Habit, category: Category) async throws
    func loadPickedImage() async throws -> UserImageSlot
    func checkIfHabitIsInCategory(habit: Habit, category: Category) async throws -> Bool
    func deleteHabitFromCategory(habit: Habit, category: Category) async throws
    //END IF
    //DEV ONLY METHOD
    //IF ADDICTIONS
    func addAddiction(addiction: Addiction) async throws
    func updateAddiction(addiction: Addiction) async throws
    func deleteAddiction(addiction: Addiction) async throws
    func createSampleAddictions(to addiction: Addiction, habit: Habit) async throws
    func addCompensatoryHabit(to addiction: Addiction, habit: Habit) async throws
    func addPreventionHabit(to addiction: Addiction, habit: Habit) async throws
    func addTriggerHabit(to addiction: Addiction, habit: Habit) async throws
    func removeCompensatoryHabit(from addiction: Addiction, habit: Habit) async throws
    func removePreventionHabit(from addiction: Addiction, habit: Habit) async throws
    func removeTriggerHabit(from addiction: Addiction, habit: Habit) async throws
    func associateCompensatoryHabit(to addiction: Addiction, habit: Habit) async throws
    func associatePreventionHabit(to addiction: Addiction, habit: Habit) async throws
    func associateTriggerHabit(to addiction: Addiction, habit: Habit) async throws
    //func associateCompensatoryHabit(to addiction: Addiction, habit: Habit) async throws
    //
    //END IF
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
    
    //IF STREAK
    //END IF
    
    func saveContext() async throws
}
