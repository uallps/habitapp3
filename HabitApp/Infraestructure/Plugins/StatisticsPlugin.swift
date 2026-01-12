import Foundation
import SwiftData

/// Plugin that notifies the StatisticsViewModel about data changes elsewhere in the app.
final class StatisticsPlugin: HabitDataObservingPlugin {
    var models: [any PersistentModel.Type]
    
    var isEnabled: Bool
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableStatistics
        self.models = []
        self.viewModel = StatisticsViewModel(storageProvider: config.storageProvider)
    }
    
    // Why was this weak var?
    var viewModel: StatisticsViewModel?

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel?.refresh()
        }
    }
}
