import SwiftData
import Foundation

final class DailyNotesPlugin: FeaturePlugin {
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    let config: AppConfig
    
    init(config: AppConfig) {
        self.isEnabled = true
        self.models = [Habit.self, DailyNote.self]
        self.config = config
    }
}
