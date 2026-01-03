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
    }
    
    // MARK: - Configuration
    
    func loadStatistics() {
        isLoading = true
        
        Task {
            do {
                let habits = try await storageProvider.loadTasks()
                
                // Compute statistics
                await MainActor.run {
                    generalStats = service.computeGeneralStats(from: habits, range: selectedRange)
                    habitStats = habits.map { service.computeHabitStats(for: $0, range: selectedRange) }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("Error loading habits for statistics: \(error)")
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        $selectedRange
            .sink { [weak self] _ in
                self?.loadStatistics()
            }
            .store(in: &cancellables)
    }
}
