import Foundation
import SwiftData
import Combine

@MainActor
class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var isLoading = false
    
    let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    // MARK: - Load
    
    func loadAchievements() async {
        isLoading = true
        do {
            achievements = try await storageProvider.loadAchievements()
            
            // Si no hay logros, crear los del catálogo
            if achievements.isEmpty {
                await initializeCatalogAchievements()
            }
        } catch {
            print("Error loading achievements: \(error)")
            achievements = []
        }
        isLoading = false
    }
    
    // MARK: - Initialize Catalog
    
    /// Crea todos los logros del catálogo al inicio (bloqueados)
    private func initializeCatalogAchievements() async {
        print("📋 Inicializando catálogo de logros...")
        
        for definition in AchievementCatalog.all {
            let achievement = Achievement(
                achievementId: definition.id,
                title: definition.title,
                description: definition.description,
                iconName: definition.iconName
            )
            achievement.isUnlocked = false
            
            do {
                try await storageProvider.saveAchievement(achievement)
            } catch {
                print("Error creando logro '\(definition.title)': \(error)")
            }
        }
        
        // Recargar después de crear
        do {
            achievements = try await storageProvider.loadAchievements()
            print("✅ \(achievements.count) logros inicializados")
        } catch {
            print("Error recargando logros: \(error)")
        }
    }
    
    // MARK: - Add
    
    func addAchievement(achievementId: String, title: String, description: String, iconName: String) async {
        let achievement = Achievement(
            achievementId: achievementId,
            title: title,
            description: description,
            iconName: iconName
        )
        
        do {
            try await storageProvider.saveAchievement(achievement)
            await loadAchievements()
        } catch {
            print("Error adding achievement: \(error)")
        }
    }
    
    // MARK: - Delete
    
    func deleteAchievement(_ achievement: Achievement) async {
        do {
            try await storageProvider.deleteAchievement(achievement)
            await loadAchievements()
        } catch {
            print("Error deleting achievement: \(error)")
        }
    }
    
    // MARK: - Toggle
    
    func toggleUnlocked(_ achievement: Achievement) async {
        achievement.isUnlocked.toggle()
        
        if achievement.isUnlocked {
            achievement.unlockedAt = Date()
        }
        
        do {
            try await storageProvider.saveContext()
            await loadAchievements()
        } catch {
            print("Error toggling achievement: \(error)")
        }
    }
    
    // MARK: - Check & Unlock
    
    /// Verifica y desbloquea logros basados en el estado actual de los hábitos
    func checkAndUnlockAchievements(completedHabit: Habit, completionDate: Date) async {
        // Validar que la fecha no sea futura
        guard completionDate <= Date() else {
            print("⚠️ No se verifica logros para fechas futuras")
            return
        }
        
        // Asegurar que los logros están cargados
        if achievements.isEmpty {
            await loadAchievements()
        }
        
        do {
            // Cargar todos los hábitos
            let allHabits = try await storageProvider.loadHabits()
            
            // Calcular estadísticas
            let totalCompletions = allHabits.reduce(0) { $0 + $1.doneDates.count }
            let uniqueHabitsCompleted = Set(allHabits.filter { !$0.doneDates.isEmpty }.map { $0.id }).count
            
            // Verificar día perfecto (solo para hoy o pasado)
            let isPerfectDay = checkPerfectDay(for: completionDate, habits: allHabits)
            
            // Calcular racha máxima del hábito completado
            let maxStreak = calculateMaxStreak(for: completedHabit)
            
            // Hora de completado
            let hour = Calendar.current.component(.hour, from: Date())
            
            // Verificar cada logro
            for definition in AchievementCatalog.all {
                // Si ya está desbloqueado, saltar
                if await isAchievementUnlocked(id: definition.id) {
                    continue
                }
                
                var shouldUnlock = false
                
                switch definition.id {
                case "first_habit":
                    shouldUnlock = totalCompletions >= 1
                    
                case "perfect_day":
                    shouldUnlock = isPerfectDay
                    
                case "habits_5":
                    shouldUnlock = totalCompletions >= 5
                    
                case "habits_25":
                    shouldUnlock = totalCompletions >= 25
                    
                case "habits_50":
                    shouldUnlock = totalCompletions >= 50
                    
                case "habits_100":
                    shouldUnlock = totalCompletions >= 100
                    
                case "streak_3":
                    shouldUnlock = maxStreak >= 3
                    
                case "streak_7":
                    shouldUnlock = maxStreak >= 7
                    
                case "early_bird":
                    shouldUnlock = hour < 8
                    
                case "variety_5":
                    shouldUnlock = uniqueHabitsCompleted >= 5
                    
                default:
                    break
                }
                
                if shouldUnlock {
                    await unlockAchievement(definition: definition)
                }
            }
            
        } catch {
            print("❌ Error verificando logros: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func isAchievementUnlocked(id: String) async -> Bool {
        return achievements.contains { $0.achievementId == id && $0.isUnlocked }
    }
    
    private func unlockAchievement(definition: AchievementDefinition) async {
        // Buscar el logro existente en lugar de crear uno nuevo
        guard let existingAchievement = achievements.first(where: { $0.achievementId == definition.id }) else {
            print("⚠️ Logro '\(definition.id)' no encontrado en la lista")
            return
        }
        
        // Actualizar el existente
        existingAchievement.isUnlocked = true
        existingAchievement.unlockedAt = Date()
        
        do {
            try await storageProvider.saveContext()
            print("🏆 ¡Logro desbloqueado! '\(definition.title)'")
        } catch {
            print("❌ Error desbloqueando logro: \(error)")
        }
    }
    
    private func checkPerfectDay(for date: Date, habits: [Habit]) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Hábitos programados para ese día
        let scheduledForDay = habits.filter { $0.scheduledDays.contains(weekday) }
        
        guard !scheduledForDay.isEmpty else { return false }
        
        // Verificar que todos estén completados en esa fecha
        let allCompleted = scheduledForDay.allSatisfy { habit in
            habit.doneDates.contains { calendar.isDate($0, inSameDayAs: date) }
        }
        
        return allCompleted
    }
    
    private func calculateMaxStreak(for habit: Habit) -> Int {
        guard !habit.doneDates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedDates = habit.doneDates.sorted()
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let previousDay = calendar.startOfDay(for: sortedDates[i-1])
            let currentDay = calendar.startOfDay(for: sortedDates[i])
            
            if let daysBetween = calendar.dateComponents([.day], from: previousDay, to: currentDay).day,
               daysBetween == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
}
