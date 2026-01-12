import Foundation
import _SwiftData_SwiftUI
import SwiftData

class SwiftDataContext {
    static var shared: ModelContext?
}

class SwiftDataStorageProvider: StorageProvider {
    
    var modelContainer: ModelContainer
    private var context: ModelContext
    
    init(schema: Schema) {
        do {
            // Schema conflict dev temp solution
            //SwiftDataStorageProvider.resetStore(schema: schema)
            //SwiftDataStorageProvider.deleteStoreFile()
            self.modelContainer = try ModelContainer(for: schema)
            self.context = ModelContext(self.modelContainer)
            SwiftDataContext.shared = self.context
        } catch {
            fatalError("Failed to initialize storage provider: \(error)")
        }
    }
    @MainActor
    func createSampleAddictions(to addiction: Addiction, habit: Habit) async throws {
        ///TODO
    }
    @MainActor
    func associatePreventionHabit(to addiction: Addiction, habit: Habit) async throws {
        ///TODO
    }
    
    @MainActor
    func getHabit(id: UUID) async throws -> Habit? {
        let habitPredicate = #Predicate<Habit> { $0.id == id }
        let habitDescriptor = FetchDescriptor<Habit>(predicate: habitPredicate)
        guard let habit = try context.fetch(habitDescriptor).first else {
            return nil
        }
        return habit
    }
    
    @MainActor
    func loadStreaksForHabit(habitId: UUID) async throws -> [Streak] {
        var streaks: [Streak] = []
        let predicate = #Predicate<Streak> { $0.habitId == habitId }
        let descriptorDebug = FetchDescriptor<Streak>()
        let descriptor = FetchDescriptor<Streak>(predicate: predicate)
        let streaksDebug = try context.fetch(descriptorDebug)
        streaks = try context.fetch(descriptor)
        return streaks
    }
    
    @MainActor
    func saveStreak(_ streak: Streak) async throws {
        context.insert(streak)
        try await saveContext()
        try await savePendingChanges()
        let descriptorDebug = FetchDescriptor<Streak>()
        let streaksDebug = try context.fetch(descriptorDebug)
        
        print("streaksDebug.count: \(streaksDebug.count)")
    }
    
    @MainActor
    func savePendingChanges() async throws {
        context.processPendingChanges()
    }
    
    @MainActor
    func loadNotes(calendar: Calendar, startOfDay: Date, endOfDay: Date, selectedDate: Date) async throws -> [DailyNote] {
        var notes: [DailyNote] = []
        do {
            let predicate = #Predicate<DailyNote> { note in
                note.date >= startOfDay && note.date < endOfDay && note.habitId == nil
            }
            
            let descriptor = FetchDescriptor<DailyNote>(
                predicate: predicate,
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            notes = try context.fetch(descriptor)
        } catch {
            print("Error loading notes: \(error)")
        }
        return notes
    }
    
    @MainActor
    func addNote(title: String, content: String, selectedDate: Date, noteDate: Date) async throws -> DailyNote {
        let note = DailyNote(title: title, content: content, date: noteDate)
        context.insert(note)
        do { try context.save() }
        catch { print("Error guardando contexto: \(error)") }
        //try await loadNotes(selectedDate: selectedDate)
        return note
    }
    
    @MainActor
    func saveContext() async throws {
        do { try context.save() }
        catch { print("Error guardando contexto: \(error)") }
   }
    
    // @MainActor
    // func updateNote(_ note: DailyNote, title: String, content: String) async throws {
    //     <#code#>
    // }
    
    // @MainActor
    // func saveAndGoToNoteDate(_ note: DailyNote, title: String, content: String) async throws {
    //     <#code#>
    // }
    
    @MainActor
    func deleteNote(_ note: DailyNote) async throws {
        context.delete(note)
    }

    @MainActor
    private func getRealInstanceAddiction(_ addiction: Addiction) -> Addiction? {
        do {
            let addictionID = addiction.id

            let descriptor = FetchDescriptor<Addiction>(
                predicate: #Predicate<Addiction> { storedAddiction in
                    storedAddiction.id == addictionID
                }
            )

            return try context.fetch(descriptor).first
        } catch {
            print("Error getting real instance of Habit: \(error)")
            return nil
        }
    }
    
    @MainActor
    func addTriggerHabit(to addiction: Addiction, habit: Habit) async throws {
        ///TODO
    }
    
    @MainActor
    func deleteGoal(_ goal: Goal) async throws {
        context.delete(goal)
        do {
            try context.save()
        } catch {
            print("Error deleting goal: \(error)")
        }
    }
    
    @MainActor
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) async throws {
        //  Forzar rollback y refetch desde el almacenamiento persistente
        context.rollback()
        
        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate<Habit> { $0.id == taskId }
        )
        
        guard let habit = try? context.fetch(descriptor).first else {
            return
        }
        
        do {
            let habitId = habit.id
            print("🔍 Hábito encontrado: '\(habit.title)' - doneDatesString: '\(habit.doneDatesString)'")
            
            let goalDescriptor = FetchDescriptor<Goal>(
                predicate: #Predicate<Goal> { goal in
                    goal.habitId == habitId
                }
            )
            let goals = try context.fetch(goalDescriptor)
            
            
            for goal in goals {
                goal.updateProgress(count: habit.doneDates.count)
                
                for milestone in goal.milestones where !milestone.isCompleted {
                    if goal.currentCount >= milestone.targetValue {
                        milestone.complete()
                    }
                }
            }
            
            try context.save()
        } catch {
            print("Error onDataChanged: \(error)")
        }
    }
    
    @MainActor
    func addAddiction(addiction: Addiction) async throws {
        if getRealInstanceAddiction(addiction) == nil {
            context.insert(addiction)
            try context.save()
        }
    }

    @MainActor
    func updateAddiction(addiction: Addiction) async throws {
        if let realAddiction = getRealInstanceAddiction(addiction) {
            realAddiction.title = addiction.title
            realAddiction.severity = addiction.severity
            realAddiction.triggers = addiction.triggers
            realAddiction.preventionHabits = addiction.preventionHabits
            realAddiction.compensatoryHabits = addiction.compensatoryHabits
            realAddiction.relapseCount = addiction.relapseCount
            try context.save()
        } else {
            print("Error updating addiction: realAddiction is nil")
        }
    }

    @MainActor
    func deleteAddiction(addiction: Addiction) async throws {
        if let realAddiction = getRealInstanceAddiction(addiction) {
            context.delete(realAddiction)
            try context.save()
        } else {
            print("Error deleting addiction: realAddiction is nil")
        }
    }

    @MainActor
    func createSampleAddictions() async throws {
       //TODO: Implement sample addictions creation
    }

    @MainActor
    func addCompensatoryHabit(to addiction: Addiction, habit: Habit) async throws {
        guard let realAddiction = getRealInstanceAddiction(addiction) else {
            print("Error adding compensatory habit: addiction is nil")
            return
        }

        guard let realHabit = getRealInstanceHabit(habit) else {
            print("Error adding compensatory habit: habit is nil")
            return
        }

        if !realAddiction.compensatoryHabits.contains(where: { $0.id == habit.id }) {
            realAddiction.compensatoryHabits.append(realHabit)
            try context.save()
        }
    }

    @MainActor
    func addPreventionHabit(to addiction: Addiction, habit: Habit) async throws {
        guard let realAddiction = getRealInstanceAddiction(addiction) else {
            print("Error adding prevention habit: addiction is nil")
            return
        }

        guard let realHabit = getRealInstanceHabit(habit) else {
            print("Error adding prevention habit: habit is nil")
            return
        }

        if !realAddiction.preventionHabits.contains(where: { $0.id == habit.id }) {
            realAddiction.preventionHabits.append(realHabit)
            try context.save()
        }
    }

    @MainActor
    func addTrigerHabit(to addiction: Addiction, habit: Habit) async throws {
        guard let realAddiction = getRealInstanceAddiction(addiction) else {
            print("Error adding trigger habit: addiction is nil")
            return
        }

        guard getRealInstanceHabit(habit) != nil else {
            print("Error adding trigger habit: habit is nil")
            return
        }

        if !realAddiction.triggers.contains(where: { $0.id == habit.id }) {
            realAddiction.triggers.append(habit)
            try context.save()
        }
    }

    @MainActor
func removeCompensatoryHabit(from addiction: Addiction, habit: Habit) async throws {
    guard getRealInstanceAddiction(addiction) != nil else {
        print("Error removing compensatory habit: addiction is nil")
        return
    }

    //if realAddiction.compensatoryHabits.id == habit.id {
        // No-op replacement; decide if you want a nullable compensatory habit instead
        print("Removed compensatory habit")
    //}

    try context.save()
}

    @MainActor
    func removePreventionHabit(from addiction: Addiction, habit: Habit) async throws {
        guard let realAddiction = getRealInstanceAddiction(addiction) else {
            print("Error removing prevention habit: addiction is nil")
            return
        }

        if let index = realAddiction.preventionHabits.firstIndex(where: { $0.id == habit.id }) {
            realAddiction.preventionHabits.remove(at: index)
            try context.save()
        }
    }

    @MainActor
    func removeTriggerHabit(from addiction: Addiction, habit: Habit) async throws {
        guard let realAddiction = getRealInstanceAddiction(addiction) else {
            print("Error removing trigger habit: addiction is nil")
            return
        }

        if let index = realAddiction.triggers.firstIndex(where: { $0.id == habit.id }) {
            realAddiction.triggers.remove(at: index)
            try context.save()
        }
    }

    @MainActor
    func associateTriggerHabit(to addiction: Addiction, habit: Habit) async throws {
        guard let realAddiction = getRealInstanceAddiction(addiction) else {
            print("Error associating trigger habit: addiction is nil")
            return
        }

        // Optional guard: only allow known triggers
        guard realAddiction.triggers.contains(where: { $0.id == habit.id }) else {
            print("Habit is not a registered trigger for this addiction")
            return
        }

        realAddiction.relapseCount += 1
        try context.save()
    }

        @MainActor
    func associateCompensatoryHabit(to addiction: Addiction, habit: Habit) async throws {
        guard getRealInstanceAddiction(addiction) != nil else {
            print("Error associating trigger habit: addiction is nil")
            return
        }

        //guard realAddiction.compensatory.contains(where: { $0.id == habit.id }) else {
            print("Habit is not a registered compensatory habit for this addiction")
           // return
       // }

        // TODO: LLAMAR A MARCAR HÁBITO COMO REALIZADO
        try context.save()
    }

        @MainActor
    func associatePreventionrHabit(to addiction: Addiction, habit: Habit) async throws {
        guard let realAddiction = getRealInstanceAddiction(addiction) else {
            print("Error associating trigger habit: addiction is nil")
            return
        }

        // Optional guard: only allow known triggers
        guard realAddiction.triggers.contains(where: { $0.id == habit.id }) else {
            print("Habit is not a registered prevention habit for this addiction")
            return
        }

        // TODO: LLAMAR A MARCAR HÁBITO COMO REALIZADO

        realAddiction.relapseCount += 1
        try context.save()
    }

    
    @MainActor
    private func getRealInstanceHabit(_ habit: Habit) -> Habit? {
        do {
            let habitID = habit.id

            let descriptor = FetchDescriptor<Habit>(
                predicate: #Predicate<Habit> { storedHabit in
                    storedHabit.id == habitID
                },
            )

            return try context.fetch(descriptor).first
        } catch {
            print("Error getting real instance of Habit: \(error)")
            return nil
        }
    }

    
    @MainActor
    private func getRealInstanceCategory(_ category: Category) -> Category? {
        do {
            let descriptor = FetchDescriptor<Category>(
                predicate: #Predicate { $0.id == category.id },
                sortBy: []
            )
            return try context.fetch(descriptor).first
        } catch {
            print("Error getting real instance of Category: \(error)")
            return nil
        }
    }
    @MainActor
    func loadPickedImage() async throws -> UserImageSlot {
        var fetchedImage: UserImageSlot? = nil
        let descriptor = FetchDescriptor<UserImageSlot>(
            sortBy: [SortDescriptor(\.id, order: .forward)]
        )
        
        do {
            fetchedImage = try context.fetch(descriptor).first
        } catch {
            print("Error loading picked image: \(error)")
        }
        let noImageArray: [Emoji] = []
        return fetchedImage ?? UserImageSlot(emojis: noImageArray)
    }
    
    @MainActor
    func addHabitToCategory(habit: Habit, category: Category) async throws {
        let realCategory = self.getRealInstanceCategory(category)
        if let realCategory {
            if !realCategory.habits.contains(where: { $0.id == habit.id } ) {
                realCategory.habits.append(habit)
            }
            try context.save()
        } else {
            print("Error adding habit to category: realCategory is nil")
        }

    }
    
    @MainActor
    func checkIfHabitIsInCategory(habit: Habit, category: Category) async throws -> Bool {
        var contains = false
        //let realHabit = self.getRealInstanceHabit(habit) TEMP UNTIL FIX WITH FRANCO
        let realHabit: Habit? = habit
        let realCategory = self.getRealInstanceCategory(category)
        if let realHabit {
                if let realCategory {
                    contains = realCategory.habits.contains(realHabit)
                }else {
                    print("Error checking if habit is in category, category is nil")
                }
        } else {
            print("Error checking if habit is in category, habit is nil")
        }
        return contains
    }
    
    @MainActor
    func deleteHabitFromCategory(habit: Habit, category: Category) async throws {
        let realHabit = self.getRealInstanceHabit(habit)
        let realCategory = self.getRealInstanceCategory(category)
        do {
            if let realHabit {
                if let realCategory {
                    let index = realCategory.habits.firstIndex(of: realHabit)
                    if let index {
                        realCategory.habits.remove(at: index)
                        try context.save()
                    } else {
                        print("Error deleting habit from category, index is nil")
                    }
                }else {
                    print("Error deleting habit from category, category is nil")
                }
            } else {
                print("Error checking deleting habit from category, habit is nil")
            }
        }catch {
            print("Error deleting habit from category, \(error)")
        }

    }
    
    @MainActor
    func addSubcategory(category: Category, subCategory: Category) async throws {
        if let realCategory = self.getRealInstanceCategory(category) {
            var realSubCategory = self.getRealInstanceCategory(subCategory)
            if realSubCategory == nil {
                context.insert(subCategory)
                try context.save()
                realSubCategory = subCategory
            }
            if !realCategory.subCategories.contains(where: { $0.id == subCategory.id }) {
                realCategory.subCategories.append(realSubCategory!)
            }
            
            try context.save()
        } else {
            print("Error adding subcategory, parent category is nil.")
        }

    }
    
    @MainActor
    func removeCategory(category: Category) async throws {
        if let trackedCategory = self.getRealInstanceCategory(category) {
            context.delete(trackedCategory)
            try context.save()
            print("Deleted category: \(trackedCategory.name)")
        } else {
            print("Category not found in context, cannot delete")
        }
    }
    
    @MainActor
    func removeSubCategory(category: Category, subCategory: Category) async throws {
        if let realCategory = self.getRealInstanceCategory(category) {
            if let realSubcategory = self.getRealInstanceCategory(subCategory) {
                let index = realCategory.subCategories.firstIndex(of: realSubcategory)
                if index != nil {
                    realCategory.subCategories.remove(at: index! )
                    context.delete(realSubcategory)
                    try context.save()
                } else {
                    print("Error removing subcategory, couldn't find realCategory on realCategory's categories")
                }
            } else {
                print("Error removing subcategory, realSubcategory is nil")
            }

        } else {
            print("Error removing category, realCategory is nil")
        }
    }
    
    func categoryExists(id: UUID) async throws -> Bool {
        let categories = try await loadCategories()
        return categories.contains(where: { $0.id == id } )
    }
    
    @MainActor
    func updateCategory(id: UUID, newCategory: Category) async throws {
        let categories = try await loadCategories()
        let oldCategory = categories.first {
            category in
            category.id == id
        }
        if let oldCategory {
            if let realOldCategory = self.getRealInstanceCategory(oldCategory) {
                realOldCategory.copyFrom(newCategory: newCategory)
                try context.save()
            } else {
                print("Couldn't update category, realOldCategory is nil")
            }
        } else {
            print("Couldn't update category, oldCategory is nil")
        }

    }
    
    @MainActor
    func upsertCategoryOrSubcategory(parent: Category?, category: Category) async throws {
        if let parent = parent {
            try await addSubcategory(category: parent, subCategory: category)
        }
        
        if try await categoryExists(id: category.id) == false {
            try await addCategory(category: category)
        }else {
            // Actualizar categoría existente
            try await updateCategory(id: category.id, newCategory: category)
            // Illegal attempt to map a relationship containing temporary objects to its identifiers.
            // It should already have been saved by context.save on addSubcategory
        }
        //try context.save() This is the real culprit to illegal attempt?
    }

    func loadTasks() async throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>()
        let tasks = try context.fetch(descriptor)
        return tasks
    }

    func saveTasks(tasks: [Habit]) async throws {
        let existingTasks = try await self.loadTasks()
        let existingIds = Set(existingTasks.map { $0.id })
        let newIds = Set(tasks.map { $0.id })
        
        for existingTask in existingTasks where !newIds.contains(existingTask.id) {
            context.delete(existingTask)
        }
        
        for task in tasks {
            if existingIds.contains(task.id) {
            } else {
                context.insert(task)
            }
        }
        
        try context.save()
    }

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.context = modelContainer.mainContext
        SwiftDataContext.shared = self.context
    }


    @MainActor
    func loadHabits() async throws -> [Habit] {
        let descriptor = FetchDescriptor<Habit>() // Use FetchDescriptor
        let habits = try context.fetch(descriptor)
        return habits
    }

    @MainActor
    func saveHabits(habits: [Habit]) async throws {
        let existingHabits = try await self.loadHabits()
        let existingIds = Set(existingHabits.map { $0.id })
        let newIds = Set(habits.map { $0.id })
        
        // Delete tasks not in the new list
        for existingHabit in existingHabits where !newIds.contains(existingHabit.id) {
            context.delete(existingHabit)
        }
        
        // Insert or update tasks
        for habit in habits {
            if existingIds.contains(habit.id) {
                // El hábito existe, asumir que está actualizado (ya que es el mismo objeto y sus propiedades no han cambiado)
            } else {
                context.insert(habit)
            }
        }
        
        try context.save()
    }
    
    @MainActor
    func loadCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        
        var categories: [Category] = []
        
        do {
            categories = try context.fetch(descriptor)
        } catch {
            print("Error loading categories: \(error)")
        }
        return categories
    }
    
    @MainActor
    func addCategory(category: Category) async throws {
        do {
            let existingCategories = try await loadCategories()
            let existingIds = Set(existingCategories.map { $0.id })

            if existingIds.contains(category.id) {
                // Category already exists
                // Option 1: do nothing
                // Option 2: update properties explicitly if needed
            } else {
                context.insert(category)
            }
            try context.save()
        } catch {
            print("Error saving category: \(error)")
        }
    }
    
    @MainActor
    func addHabit(habit: Habit) async  throws {
        do {
            context.insert(habit)
            try await saveContext()
        } catch {
            print("Error adding habit: \(error)")
        }
    }
    
    // @MainActor
    // func updateHabit(habit: Habit) {
    //     do {
    //         try await storageProvider.context.save()
    //     } catch {
    //         print("Error updating habit: \(error)")
    //     }
    // }
    
    @MainActor
    func deleteHabit(habit: Habit) async throws {
        do {
            if let realHabit = getRealInstanceHabit(habit) {
                context.delete(realHabit)
                try await saveContext()
            }

        } catch {
            print("Error deleting habit: \(error)")
        }

    }
    
    // Este archivo existe para borrar toda la información de la base de datos local.
    // Es especialmente útil cuando existe un conflicto en los esquemas de un ordenador MacOS.

    // Como es evidente, tiene sentido en un entorno de desarrollo y pruebas. A no ser que
    //se quiera dejar una gran vulnerabilidad o trollear un poquito al usuario final, no
    // debería de existir.
        @MainActor
        func resetStorage() {
            // 1. Tear down old context and container
            SwiftDataContext.shared = nil
            // Note: Old modelContainer will be deallocated automatically
            
            // 2. Recreate a new container and context
            do {
                let newContainer = try ModelContainer(for: Schema()) // your app schema
                let newContext = ModelContext(newContainer)
                self.modelContainer = newContainer
                self.context = newContext
                SwiftDataContext.shared = newContext
                print("✅ SwiftData storage reset complete.")
            } catch {
                print("❌ Failed to reset SwiftData storage: \(error)")
            }
        }
    
    static func resetStore(schema: Schema) {
        do {
            let container = try ModelContainer(for: schema)
            container.deleteAllData()
            print("SwiftData store reset")
        } catch {
            print("SwiftData reset failed: \(error)")
        }
    }
    
    static func deleteStoreFile() {
        let url = URL.applicationSupportDirectory
            .appending(path: "HabitApp.store")

        try? FileManager.default.removeItem(at: url)
    }}




