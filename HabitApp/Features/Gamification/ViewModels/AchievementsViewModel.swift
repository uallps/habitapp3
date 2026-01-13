import Foundation
import SwiftData
import Combine

@MainActor
class AchievementsViewModel: ObservableObject {
    let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    // MARK: - Public
    
    func syncCatalogIfNeeded() async {
        do {
            let storedAchievements = try await storageProvider.loadAchievements()
            let catalogIds = Set(AchievementCatalog.all.map { $0.id })
            
            // Eliminar logros obsoletos que ya no estén en el catálogo
            for achievement in storedAchievements where !catalogIds.contains(achievement.achievementId) {
                try await storageProvider.deleteAchievement(achievement)
            }
            
            let existingIds = Set(
                storedAchievements
                    .filter { catalogIds.contains($0.achievementId) }
                    .map { $0.achievementId }
            )
            
            for definition in AchievementCatalog.all {
                if !existingIds.contains(definition.id) {
                    let achievement = Achievement(
                        achievementId: definition.id,
                        title: definition.title,
                        description: definition.description,
                        iconName: definition.iconName
                    )
                    achievement.isUnlocked = false
                    try await storageProvider.saveAchievement(achievement)
                }
            }
        } catch {
            print("❌ Error sincronizando logros: \(error)")
        }
    }
    
    /// Verifica y desbloquea logros basados en el estado actual de los hábitos
    /// Usa directamente la lista de hábitos que ya tiene la vista (mismo contexto de SwiftData)
    func checkAndUnlockAchievements(habits: [Habit]) async {
        do {
            let achievements = try await storageProvider.loadAchievements()
            
            let lockedAchievements = achievements.filter { !$0.isUnlocked }
            guard !lockedAchievements.isEmpty else { return }
            
            // MARK: - Estadísticas globales
            
            let calendar = Calendar.current
            
            let allCompletionDates = habits
                .flatMap { $0.doneDates }
                .map { calendar.startOfDay(for: $0) }
            
            // Calcular la fecha más reciente para verificaciones temporales (perfect_day, early_bird)
            let triggeringDate = allCompletionDates.max() ?? Date()
            
            let totalCompletions = allCompletionDates.count
            let uniqueHabitsCompleted = Set(
                habits.filter { !$0.doneDates.isEmpty }.map { $0.id }
            ).count
            
            let maxHabitStreak = habits
                .map { calculateMaxStreak(for: $0) }
                .max() ?? 0
            
            let globalStreak = calculateGlobalStreak(from: allCompletionDates)

            let isPerfectDay = checkPerfectDay(
                for: triggeringDate,
                habits: habits
            )
            
            let hasWeekendCompletion = allCompletionDates.contains { date in
                let weekday = calendar.component(.weekday, from: date)
                return weekday == 1 || weekday == 7 // domingo o sábado
            }
            
            let hasLowPriorityCompletion = habits.contains { habit in
                habit.priority == .low && !habit.doneDates.isEmpty
            }
            
            let hasHighPriorityCompletion = habits.contains { habit in
                habit.priority == .high && !habit.doneDates.isEmpty
            }
            
            let hasPerfectWeek = calculatePerfectWeek(habits: habits, allCompletionDates: allCompletionDates)
            
            print("📊 ESTADÍSTICAS CALCULADAS:")
            print("  Total de completados: \(totalCompletions)")
            print("  Hábitos únicos completados: \(uniqueHabitsCompleted)")
            print("  Racha individual máxima: \(maxHabitStreak)")
            print("  Racha global: \(globalStreak)")
            print("  Día perfecto: \(isPerfectDay)")
            print("  Fin de semana completado: \(hasWeekendCompletion)")
            print("  Perfect week: \(hasPerfectWeek)")
            
            // Debug: mostrar fechas de cada hábito
            for habit in habits where !habit.doneDates.isEmpty {
                let streak = calculateMaxStreak(for: habit)
                print("  - \(habit.title): \(habit.doneDates.count) días, streak: \(streak)")
            }
            

            
            // MARK: - Evaluación de logros
            
            var unlockedCount = 0
            
            for achievement in lockedAchievements {
                guard let definition = AchievementCatalog.find(id: achievement.achievementId) else {
                    continue
                }
                
                let shouldUnlock: Bool
                
                switch definition.id {
                case "first_habit":
                    shouldUnlock = totalCompletions >= 1
                    
                case "habits_5":
                    shouldUnlock = totalCompletions >= 5
                    
                case "habits_25":
                    shouldUnlock = totalCompletions >= 25
                    
                case "habits_50":
                    shouldUnlock = totalCompletions >= 50
                    
                case "habits_100":
                    shouldUnlock = totalCompletions >= 100
                    
                case "perfect_day":
                    shouldUnlock = isPerfectDay
                    
                case "streak_3":
                    shouldUnlock = maxHabitStreak >= 3
                    
                case "streak_7":
                    shouldUnlock = maxHabitStreak >= 7
                    
                case "global_streak_7":
                    shouldUnlock = globalStreak >= 7
                    
                case "global_streak_30":
                    shouldUnlock = globalStreak >= 30
                    
                case "variety_5":
                    shouldUnlock = uniqueHabitsCompleted >= 5
                    
                case "weekend_aguafiestas":
                    shouldUnlock = hasWeekendCompletion
                    
                case "perfect_week":
                    shouldUnlock = hasPerfectWeek
                    
                case "low_priority_done":
                    shouldUnlock = hasLowPriorityCompletion
                    
                case "high_priority_done":
                    shouldUnlock = hasHighPriorityCompletion
                    
                default:
                    shouldUnlock = false
                }
                
                if shouldUnlock {
                    achievement.isUnlocked = true
                    achievement.unlockedAt = Date()
                    unlockedCount += 1
                }
            }
            
            if unlockedCount > 0 {
                try await storageProvider.saveContext()
            }
            
        } catch {
            print("❌ Error comprobando logros: \(error)")
        }
    }
    
    // MARK: - Scoring
    
    /// Calcula la puntuación total a partir de los logros desbloqueados.
    func totalScore(for achievements: [Achievement]) -> Int {
        achievements.filter { $0.isUnlocked }.reduce(0) { partial, achievement in
            guard let definition = AchievementCatalog.find(id: achievement.achievementId) else { return partial }
            return partial + definition.points
        }
    }
    
    /// Devuelve el nivel asociado a una puntuación dada.
    func level(forScore score: Int) -> AchievementLevel {
        AchievementLevel(score: score)
    }
    
    // MARK: - Helpers
    
    private func checkPerfectDay(for date: Date, habits: [Habit]) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        let scheduledHabits = habits.filter {
            $0.scheduledDays.isEmpty || $0.scheduledDays.contains(weekday)
        }
        
        guard !scheduledHabits.isEmpty else { return false }
        
        return scheduledHabits.allSatisfy { habit in
            habit.doneDates.contains {
                calendar.isDate($0, inSameDayAs: date)
            }
        }
    }
    
    private func calculateMaxStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current
        
        let dates = habit.doneDates
            .map { calendar.startOfDay(for: $0) }
            .sorted()
        
        guard dates.count > 1 else {
            return dates.isEmpty ? 0 : 1
        }
        
        var maxStreak = 1
        var current = 1
        
        for i in 1..<dates.count {
            if calendar.dateComponents([.day], from: dates[i - 1], to: dates[i]).day == 1 {
                current += 1
                maxStreak = max(maxStreak, current)
            } else {
                current = 1
            }
        }
        
        return maxStreak
    }
    
    private func calculateGlobalStreak(from dates: [Date]) -> Int {
        let sortedDates = Array(Set(dates)).sorted()
        guard sortedDates.count > 1 else {
            return sortedDates.isEmpty ? 0 : 1
        }
        
        let calendar = Calendar.current
        var maxStreak = 1
        var current = 1
        
        for i in 1..<sortedDates.count {
            if calendar.dateComponents([.day], from: sortedDates[i - 1], to: sortedDates[i]).day == 1 {
                current += 1
                maxStreak = max(maxStreak, current)
            } else {
                current = 1
            }
        }
        
        return maxStreak
    }

    /// Devuelve true si existe una ventana de 7 días consecutivos
    /// en la que todos los días son "perfect_day" para los hábitos actuales.
    private func calculatePerfectWeek(habits: [Habit], allCompletionDates: [Date]) -> Bool {
        let calendar = Calendar.current
        let uniqueDays = Array(Set(allCompletionDates)).sorted()
        guard uniqueDays.count >= 7 else { return false }
        
        let daySet = Set(uniqueDays)
        
        for startDay in uniqueDays {
            var allPerfect = true
            var currentDay = startDay
            
            for _ in 0..<7 {
                // Comprobar que el día existe en el conjunto de días con completados
                if !daySet.contains(currentDay) || !checkPerfectDay(for: currentDay, habits: habits) {
                    allPerfect = false
                    break
                }
                
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else {
                    allPerfect = false
                    break
                }
                currentDay = calendar.startOfDay(for: nextDay)
            }
            
            if allPerfect {
                return true
            }
        }
        
        return false
    }
}
