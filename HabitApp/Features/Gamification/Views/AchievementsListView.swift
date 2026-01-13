import SwiftUI
import SwiftData

struct AchievementsListView: View {
    @StateObject private var viewModel: AchievementsViewModel
    
    @Query(sort: \Achievement.achievementId)
    private var achievements: [Achievement]
    
    @Query
    private var habits: [Habit]
    
    init(storageProvider: StorageProvider) {
        _viewModel = StateObject(
            wrappedValue: AchievementsViewModel(storageProvider: storageProvider)
        )
    }
    
    // MARK: - Scoring
    
    private var totalScore: Int {
        viewModel.totalScore(for: achievements)
    }
    
    private var currentLevel: AchievementLevel {
        viewModel.level(forScore: totalScore)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if achievements.isEmpty {
                    ProgressView("Cargando logros...")
                } else {
                    List {
                        Section {
                            ForEach(achievements) { achievement in
                                AchievementRowView(achievement: achievement)
                            }
                        } header: {
                            ScoreHeaderView(totalScore: totalScore, level: currentLevel)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Logros")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.syncCatalogIfNeeded()
                await viewModel.checkAndUnlockAchievements(habits: habits)
            }
            .onChange(of: habits) { _, newHabits in
                Task {
                    await viewModel.checkAndUnlockAchievements(habits: newHabits)
                }
            }
        }
    }
}
