import SwiftData
import Foundation

final class CategoryPlugin: HabitDataObservingPlugin {
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        Task {
            try await config.storageProvider.onDataChanged(taskId: taskId, title: title, dueDate: dueDate)
        }
    }
    
    var models: [any PersistentModel.Type]
    
    var isEnabled: Bool
    
    let config: AppConfig
    
    init(config: AppConfig) {
        self.config = config
        self.models = [Habit.self, Category.self, Emoji.self, UserImageSlot.self]
        self.isEnabled = config.userPreferences.enableCategories
    }
    
    
}

