import Foundation
import SwiftData

final class AddictionPlugin: HabitDataObservingPlugin {
    
    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        Task {
            try await storageProvider.onDataChanged(taskId: taskId, title: title, dueDate: dueDate)
        }
    }
    
    let storageProvider: StorageProvider
    
    
    var models: [any PersistentModel.Type]
    
    var isEnabled: Bool
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.showAddictions
        self.models = [Habit.self, Addiction.self]
        self.storageProvider = config.storageProvider
    }
    
    
}
