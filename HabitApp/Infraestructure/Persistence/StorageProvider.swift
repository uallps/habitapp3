import Foundation

protocol StorageProvider {
    func loadHabits() async throws -> [Habit]
    func saveHabits(habits: [Habit]) async throws
    //IF CATEGORY
    func loadCategories() async throws -> [UUID:Category]
    func addCategory(category: Category) async throws
    func addSubcategory(category: Category, subCategory: Category) async throws
    func removeCategory(category: Category) async throws
    func removeSubCategory(category: Category, subCategory: Category) async throws
    func categoryExists(id: UUID) async throws -> Bool
    func updateCategory(id: UUID, newCategory: Category) async throws
    func upsertCategoryOrSubcategory(parent: Category?, category: Category) async throws
    func addHabitToCategory(habit: Habit, category: Category) async throws
    func loadPickedImage() async throws
    //END IF
}
