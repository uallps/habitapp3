import Foundation

protocol StorageProvider {
    func loadHabits() async throws -> [Habit]
    func saveHabits(habits: [Habit]) async throws
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
    func addAddiction(_Addiction: Addiction) async throws
    func updateAddiction(_Addiction: Addiction) async throws
    func deleteAddiction(_Addiction: Addiction) async throws
    func createSampleAddictions(to addiction: Addiction, habit: Habit) async throws
    func addCompensatoryHabit(to addiction: Addiction, habit: Habit) async throws
    func addPreventionHabit(to addiction: Addiction, habit: Habit) async throws
    func addTrigerHabit(to addiction: Addiction, habit: Habit) async throws
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
    //IF GOALPLUGIN
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) async throws 
    //END GOALPLUGIN
}
