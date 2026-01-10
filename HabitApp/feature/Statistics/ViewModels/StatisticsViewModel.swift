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
    
    private let service = StatisticsService()
    
    // MARK: - Initialization
    
    init() {}

    // MARK: - Public Helpers

    func loadStatistics(from habits: [Habit]) {
        // Compute statistics from a provided list
        generalStats = service.computeGeneralStats(from: habits, range: selectedRange)
        habitStats = habits.map { service.computeHabitStats(for: $0, range: selectedRange) }
    }
}
