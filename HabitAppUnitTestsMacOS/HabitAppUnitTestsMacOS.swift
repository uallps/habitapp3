import Testing
@testable import HabitApp

struct HabitAppUnitTestsMacOS {

    @Test func nestThreeCategoriesSequentially() async throws {
        let iconSetParent = [Emoji(emoji: "🚙", name: "vehicle")]
        let iconSetChild = [Emoji(emoji: "🧽", name: "sponge")]
        let iconSetChildOfChild = [Emoji(emoji: "💺", name: "seat")]
        
        let parentCategory = Category(
            name: "Coche",
            icon: UserImageSlot(emojis: iconSetParent),
            priority: Priority.medium,
            isSubcategory: false
        )
        
        let childOfParentCategory = Category(
            name: "Limpieza",
            icon: UserImageSlot(emojis: iconSetChild),
            priority: Priority.high,
            isSubcategory: true
        )
        
        let childOfChildCategory = Category(
            name: "Asientos",
            icon: UserImageSlot(emojis: iconSetChildOfChild),
            priority: Priority.high,
            isSubcategory: true
        )
        
        let categoryListVM = await CategoryListViewModel()
        
        await categoryListVM.upsertCategoryOrSubcategory(
            parent: nil,
            category: parentCategory
        )
        
        #expect (categoryListVM.categories.count == 1)

        await categoryListVM.upsertCategoryOrSubcategory(
            parent: parentCategory,
            category: childOfParentCategory
        )
        
        #expect (categoryListVM.categories.count == 1)

        await categoryListVM.upsertCategoryOrSubcategory(
            parent: childOfParentCategory,
            category: childOfChildCategory
        )
        
        #expect (categoryListVM.categories.count == 1)
        #expect (parentCategory.subCategories.count == 1)
        #expect(parentCategory.subCategories[childOfParentCategory.name]?.subCategories.count == 1)
    }

}
