import Foundation
import SwiftData
import Combine

@MainActor
final class StatisticsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedRange: TimeRange = .week
    @Published var generalStats: GeneralStats?
    @Published var habitStats: [HabitStats] = []
    @Published var isLoading = false
    
    // MARK: - Private Properties
    
    private let storageProvider: StorageProvider
    private let service = StatisticsService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        setupObservers()
        // Register a plugin so the view model gets notified when other parts of the app change data
        PluginRegistry.shared.register(plugin: StatisticsPlugin(viewModel: self))
    }

    // Public API for external triggers (plugin) to force a refresh from storageProvider
    func refresh() {
        fetchHabitsAndLoad()
    }

    // MARK: - Public Helpers

    func loadStatistics(from habits: [Habit]) {
        // Compute statistics from a provided list
        generalStats = service.computeGeneralStats(from: habits, range: selectedRange)
        habitStats = habits.map { service.computeHabitStats(for: $0, range: selectedRange) }
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        $selectedRange
            .sink { [weak self] _ in
                // When range changes, re-fetch from storageProvider to ensure fresh data
                guard let self = self else { return }
                self.fetchHabitsAndLoad()
            }
            .store(in: &cancellables)
    }

    func fetchHabitsAndLoad() {
        let context = storageProvider.context
        isLoading = true
        
        // Fetch habits
        let descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        
        do {
            let habits = try context.fetch(descriptor)
            // Use the unified load path to compute
            loadStatistics(from: habits)
            isLoading = false
        } catch {
            print("Error loading habits for statistics: \(error)")
            isLoading = false
        }
    }
}
