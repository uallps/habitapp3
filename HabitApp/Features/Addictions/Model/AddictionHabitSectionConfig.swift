import SwiftUI
import SwiftData

struct AddictionHabitSectionConfig {
    let title: String
    let emptyText: String
    let habits: [Habit]

    let onAssociate: (Habit) async -> Void
    let onRemove: (Habit) async -> Void
    let onAdd: (Habit) async -> Void
}

