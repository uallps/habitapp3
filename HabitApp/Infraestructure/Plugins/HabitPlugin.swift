import SwiftData

final class HabitPlugin: DataPlugin {
    var models: [any PersistentModel.Type]
    
    var isEnabled: Bool
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableHabits
        self.models = [Habit.self]
    }
    
}
