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
    
    var body: some View {
        NavigationStack {
            Group {
                if achievements.isEmpty {
                    ProgressView("Cargando logros...")
                } else {
                    List(achievements) { achievement in
                        AchievementRowView(achievement: achievement)
                    }
                }
            }
            .navigationTitle("Logros")
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
