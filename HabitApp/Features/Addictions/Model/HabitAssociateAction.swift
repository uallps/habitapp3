enum HabitAssociationAction {
    case immediate((Habit) async -> Void)
    case confirm(
        title: String,
        message: String,
        confirmLabel: String,
        action: (Habit) async -> Void
    )
}
