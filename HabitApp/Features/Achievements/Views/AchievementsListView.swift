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
        #if os(iOS)
        iosBody
        #else
        macBody
        #endif
    }
}

// MARK: - iOS UI

#if os(iOS)
extension AchievementsListView {
    var iosBody: some View {
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
#endif

// MARK: - macOS UI

#if os(macOS)
extension AchievementsListView {
    var macBody: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.06),
                        Color.purple.opacity(0.04)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Encabezado con puntuación y nivel
                    ScoreHeaderView(totalScore: totalScore, level: currentLevel)
                        .padding(.top, 12)
                        .padding(.horizontal)
                    
                    if achievements.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Image(systemName: "trophy")
                                .font(.system(size: 64))
                                .foregroundColor(.yellow.opacity(0.7))
                            
                            Text("Sin logros todavía")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Completa tus hábitos para empezar a desbloquear logros.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 360)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 8) {
                                ForEach(achievements) { achievement in
                                    AchievementRowView(achievement: achievement)
                                        .padding(.horizontal)
                                        .padding(.vertical, 4)
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                }
            }
            .navigationTitle("Logros")
            .frame(minWidth: 600, minHeight: 400)
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
#endif
