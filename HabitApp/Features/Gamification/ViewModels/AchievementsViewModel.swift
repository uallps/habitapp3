import Foundation
import SwiftData
import Combine

@MainActor
class AchievementsViewModel: ObservableObject {
    let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
    }
    
    func syncCatalogIfNeeded() async {
        do {
            let storedAchievements = try await storageProvider.loadAchievements()
            let storedIds = Set(storedAchievements.map { $0.achievementId })

            for definition in AchievementCatalog.all {
                if !storedIds.contains(definition.id) {
                    let achievement = Achievement(
                        achievementId: definition.id,
                        title: definition.title,
                        description: definition.description,
                        iconName: definition.iconName
                    )
                    achievement.isUnlocked = false

                    try await storageProvider.saveAchievement(achievement)
                    print("➕ Nuevo logro agregado: \(definition.id)")
                }
            }
        } catch {
            print("❌ Error sincronizando logros: \(error)")
        }
    }

    /// Verifica y desbloquea logros basados en el estado actual de los hábitos
    func checkAndUnlockAchievements(triggeringDate: Date = Date()) async {
        print("\n🎯 === VERIFICANDO LOGROS ===")
        print("Fecha de verificación: \(triggeringDate)")
        
        do {
            // Cargar todos los hábitos y logros
            let allHabits = try await storageProvider.loadHabits()
            let allAchievements = try await storageProvider.loadAchievements()
            
            // Filtrar solo logros NO desbloqueados (optimización)
            let lockedAchievements = allAchievements.filter { !$0.isUnlocked }
            
            guard !lockedAchievements.isEmpty else {
                print("✅ Todos los logros ya están desbloqueados")
                return
            }
            
            print("📊 Logros pendientes: \(lockedAchievements.count)/\(allAchievements.count)")
            
            // Calcular estadísticas globales
            let totalCompletions = allHabits.reduce(0) { $0 + $1.doneDates.count }
            let uniqueHabitsCompleted = Set(allHabits.filter { !$0.doneDates.isEmpty }.map { $0.id }).count
            
            print("\n📊 ESTADÍSTICAS:")
            print("  Total completados: \(totalCompletions)")
            print("  Hábitos únicos: \(uniqueHabitsCompleted)")
            
            // Verificar día perfecto para la fecha específica
            let isPerfectDay = checkPerfectDay(for: triggeringDate, habits: allHabits)
            print("  Día perfecto (\(triggeringDate)): \(isPerfectDay ? "✅" : "❌")")
            
            // Calcular racha MÁXIMA entre TODOS los hábitos (individual)
            let maxStreak = allHabits.map { calculateMaxStreak(for: $0) }.max() ?? 0
            print("  Racha máxima individual: \(maxStreak)")
            
            // Calcular racha GLOBAL (días consecutivos con al menos 1 hábito)
            let globalStreak = calculateGlobalStreak(habits: allHabits)
            print("  Racha global: \(globalStreak)")
            
            // Hora de la fecha de verificación (para early_bird)
            let hour = Calendar.current.component(.hour, from: triggeringDate)
            print("  Hora de verificación: \(hour)h")
            
            // Verificar cada logro SOLO si NO está desbloqueado
            print("\n🔍 VERIFICANDO LOGROS:")
            for achievement in lockedAchievements {
                guard let definition = AchievementCatalog.find(id: achievement.achievementId) else {
                    continue
                }
                
                var shouldUnlock = false
                var reason = ""
                
                switch definition.id {
                case "first_habit":
                    shouldUnlock = totalCompletions >= 1
                    reason = "\(totalCompletions) >= 1"
                    
                case "perfect_day":
                    shouldUnlock = isPerfectDay
                    reason = "isPerfectDay = \(isPerfectDay)"
                    
                case "habits_5":
                    shouldUnlock = totalCompletions >= 5
                    reason = "\(totalCompletions) >= 5"
                    
                case "habits_25":
                    shouldUnlock = totalCompletions >= 25
                    reason = "\(totalCompletions) >= 25"
                    
                case "habits_50":
                    shouldUnlock = totalCompletions >= 50
                    reason = "\(totalCompletions) >= 50"
                    
                case "habits_100":
                    shouldUnlock = totalCompletions >= 100
                    reason = "\(totalCompletions) >= 100"
                    
                case "streak_3":
                    shouldUnlock = maxStreak >= 3
                    reason = "\(maxStreak) >= 3"
                    
                case "streak_7":
                    shouldUnlock = maxStreak >= 7
                    reason = "\(maxStreak) >= 7"
                    
                case "global_streak_7":
                    shouldUnlock = globalStreak >= 7
                    reason = "\(globalStreak) >= 7"
                    
                case "global_streak_30":
                    shouldUnlock = globalStreak >= 30
                    reason = "\(globalStreak) >= 30"
                    
                case "early_bird":
                    shouldUnlock = hour < 8
                    reason = "\(hour)h < 8h"
                    
                case "variety_5":
                    shouldUnlock = uniqueHabitsCompleted >= 5
                    reason = "\(uniqueHabitsCompleted) >= 5"
                    
                default:
                    break
                }
                
                if shouldUnlock {
                    print("  ✅ \(definition.id): DESBLOQUEADO (\(reason))")
                    await unlockAchievement(achievement: achievement)
                } else {
                    print("  🔒 \(definition.id): bloqueado (\(reason))")
                }
            }
            
            print("✅ === VERIFICACIÓN COMPLETADA ===\n")
            
        } catch {
            print("❌ Error verificando logros: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func unlockAchievement(achievement: Achievement) async {
        achievement.isUnlocked = true
        achievement.unlockedAt = Date()
        
        do {
            try await storageProvider.saveContext()
            print("🏆 ¡Logro desbloqueado! '\(achievement.title)'")
        } catch {
            print("❌ Error desbloqueando logro: \(error)")
        }
    }
    
    private func checkPerfectDay(for date: Date, habits: [Habit]) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        print("\n🗓️ checkPerfectDay para fecha: \(date)")
        print("   Día de la semana: \(weekday) (1=Dom, 2=Lun, ..., 7=Sáb)")
        
        // Hábitos programados para ese día
        let scheduledForDay = habits.filter { $0.scheduledDays.contains(weekday) }
        
        print("   Hábitos programados ese día: \(scheduledForDay.count)")
        scheduledForDay.forEach { habit in
            let isCompleted = habit.doneDates.contains { calendar.isDate($0, inSameDayAs: date) }
            print("     - \(habit.title): \(isCompleted ? "✅" : "❌")")
        }
        
        guard !scheduledForDay.isEmpty else {
            print("   ⚠️ No hay hábitos programados para ese día")
            return false
        }
        
        // Verificar que todos estén completados en esa fecha
        let allCompleted = scheduledForDay.allSatisfy { habit in
            habit.doneDates.contains { calendar.isDate($0, inSameDayAs: date) }
        }
        
        print("   Resultado: \(allCompleted ? "✅ DÍA PERFECTO" : "❌ No perfecto")")
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
    
    private func calculateGlobalStreak(habits: [Habit]) -> Int {
        // Obtener todas las fechas únicas de completado de TODOS los hábitos
        let calendar = Calendar.current
        var allDates = Set<Date>()
        
        for habit in habits {
            for date in habit.doneDates {
                allDates.insert(calendar.startOfDay(for: date))
            }
        }
        
        guard !allDates.isEmpty else { return 0 }
        
        let sortedDates = allDates.sorted()
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let previousDay = sortedDates[i-1]
            let currentDay = sortedDates[i]
            
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
