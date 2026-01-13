import Foundation
import SwiftData

final class AddictionPlugin: HabitDataObservingPlugin {
    
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        Task {
            try await config.storageProvider.onDataChanged(taskId: taskId, title: title, dueDate: dueDate)
        }
    }
    
    var models: [any PersistentModel.Type]
    let config: AppConfig
    var isEnabled: Bool
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableAddictions
        self.models = [Habit.self, Addiction.self]
        self.config = config
    }
    
    
}
