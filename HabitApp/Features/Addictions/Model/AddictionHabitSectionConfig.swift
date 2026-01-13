import SwiftUI
import SwiftData

struct AddictionHabitSectionConfig {
    let title: String
    let emptyText: String
    let habits: [Habit]
    
    let onAssociate: (Habit, [Habit]) async -> Void
    let onRemove: (Habit, [Habit]) async -> Void
    let onTap: (Habit, [Habit]) async -> Void
}

