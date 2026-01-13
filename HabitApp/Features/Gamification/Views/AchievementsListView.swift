import SwiftUI
import SwiftData

struct AchievementsListView: View {
    @StateObject private var viewModel: AchievementsViewModel
    @Query(sort: \Achievement.achievementId) private var achievements: [Achievement]
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    
    init(storageProvider: StorageProvider) {
        _viewModel = StateObject(wrappedValue: AchievementsViewModel(storageProvider: storageProvider))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if achievements.isEmpty {
                    ProgressView("Cargando logros...")
                } else {
                    List {
                        ForEach(achievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                }
            }
            .navigationTitle("Logros (\(achievements.count))")
            .task {
                // Sincronizar catálogo (agrega nuevos logros si los hay)
                await viewModel.syncCatalogIfNeeded()
            }
            .onChange(of: habits.map { $0.doneDates.count }) { oldValue, newValue in
                // Solo verificar si hubo un incremento (completado), no decremento (descompletado)
                let oldTotal = oldValue.reduce(0, +)
                let newTotal = newValue.reduce(0, +)
                
                guard newTotal > oldTotal else {
                    return
                }
                
                // Detectar cambio en completados y verificar logros
                if let lastModifiedHabit = habits.max(by: { ($0.doneDates.last ?? .distantPast) < ($1.doneDates.last ?? .distantPast) }),
                   let lastDate = lastModifiedHabit.doneDates.last {
                    Task {
                        await viewModel.checkAndUnlockAchievements(triggeringDate: lastDate)
                    }
                }
            }
        }
    }
}

// MARK: - Achievement Row

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            // Icono
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundColor(achievement.isUnlocked ? .blue : .gray)
            }
            
            // Texto
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.achievementDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if achievement.isUnlocked, let unlockedDate = achievement.unlockedAt {
                    Text("Desbloqueado: \(unlockedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Estado
            Image(systemName: achievement.isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                .foregroundColor(achievement.isUnlocked ? .green : .gray)
                .font(.title3)
        }
        .padding(.vertical, 8)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}
