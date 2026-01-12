import Foundation
import SwiftData

/// Plugin that notifies the StatisticsViewModel about data changes elsewhere in the app.
final class StatisticsPlugin: HabitDataObservingPlugin {
    var models: [any PersistentModel.Type]
    
    var isEnabled: Bool
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableStatistics
        self.models = []
        self.config = config
        self.viewModel = nil
    }
    
    private weak var config: AppConfig?
    var viewModel: StatisticsViewModel?

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.viewModel == nil {
                if let provider = self.config?.storageProvider {
                    self.viewModel = StatisticsViewModel(storageProvider: provider)
                } else {
                    return
                }
            }
            self.viewModel?.refresh()
        }
    }
}
