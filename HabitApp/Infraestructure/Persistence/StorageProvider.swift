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
    func resetStorage()
    //END DEV ONLY METHOD
}
