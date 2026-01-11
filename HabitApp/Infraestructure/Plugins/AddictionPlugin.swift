import Foundation
import SwiftData

final class AddictionPlugin: DataPlugin {
    
    var models: [any PersistentModel.Type]
    
    var isEnabled: Bool
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.showAddictions
        self.models = [Habit.self, Addiction.self]
    }
    
    
}
