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
    
    private var modelContext: ModelContext?
    private let service = StatisticsService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        setupObservers()
    }
    
    // MARK: - Configuration
    
    func configure(with context: ModelContext) {
        self.modelContext = context
        loadStatistics()
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        $selectedRange
            .sink { [weak self] _ in
                self?.loadStatistics()
            }
            .store(in: &cancellables)
    }
    
    func loadStatistics() {
        guard let modelContext else { return }
        
        isLoading = true
        
        // Fetch habits
        let descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        
        do {
            let habits = try modelContext.fetch(descriptor)
            
            // Compute statistics
            generalStats = service.computeGeneralStats(from: habits, range: selectedRange)
            habitStats = habits.map { service.computeHabitStats(for: $0, range: selectedRange) }
            
            isLoading = false
        } catch {
            print("Error loading habits for statistics: \(error)")
            isLoading = false
        }
    }
}
