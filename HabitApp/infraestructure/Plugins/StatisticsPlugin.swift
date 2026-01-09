import Foundation

/// Plugin that notifies the StatisticsViewModel about data changes elsewhere in the app.
final class StatisticsPlugin: TaskDataObservingPlugin {
    weak var viewModel: StatisticsViewModel?

    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
    }

    func onDataChanged(taskId: UUID, title: String, dueDate: Date?) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel?.refresh()
        }
    }
}
