import Testing
import Foundation
@testable import HabitApp

// MARK: - Estadísticas

@Suite("Statistics")
struct StatisticsServiceTests {
    @Test("computeGeneralStats cuenta completados del día")
    func generalStatsForToday() {
        let service = StatisticsService()
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)

        // Hábito programado y completado hoy
        let completedHabit = Habit(
            title: "Ejercicio",
            doneDates: [today],
            scheduledDays: [weekday]
        )

        // Hábito programado pero no completado hoy
        let pendingHabit = Habit(
            title: "Leer",
            doneDates: [],
            scheduledDays: [weekday]
        )

        let stats = service.computeGeneralStats(from: [completedHabit, pendingHabit], range: .day)

        #expect(stats.totalCompleted == 1)
        #expect(stats.totalExpected == 2)
        #expect(stats.periods.count == 1)
    }

    @Test("computeHabitStats devuelve períodos para la semana")
    func habitStatsForWeekRange() {
        let service = StatisticsService()
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)

        // Hábito programado y completado hoy
        let habit = Habit(
            title: "Meditar",
            doneDates: [today],
            scheduledDays: [weekday]
        )

        let stats = service.computeHabitStats(for: habit, range: .week)

        #expect(stats.periods.count == 7)
        #expect(stats.totalCompleted == 1)
        #expect(stats.totalExpected == 1)
    }
}

// MARK: - Logros

@Suite("Achievements")
struct AchievementsTests {
    @Test("El catálogo contiene algunos IDs conocidos")
    func catalogContainsKnownIds() {
        let firstHabit = AchievementCatalog.find(id: "first_habit")
        let perfectWeek = AchievementCatalog.find(id: "perfect_week")

        #expect(firstHabit != nil)
        #expect(perfectWeek != nil)
        #expect(firstHabit?.points == 10)
        #expect(perfectWeek?.points == 50)
    }

    @Test("Los IDs de logros del catálogo son únicos")
    func catalogIdsAreUnique() {
        let ids = AchievementCatalog.all.map { $0.id }
        let uniqueIds = Set(ids)

        #expect(ids.count == uniqueIds.count)
    }

    @Test("Achievement se inicializa bloqueado por defecto")
    func achievementStartsLocked() {
        let achievement = Achievement(
            achievementId: "test_id",
            title: "Prueba",
            description: "",
            iconName: "star"
        )

        #expect(achievement.isUnlocked == false)
        #expect(achievement.unlockedAt == nil)
    }

    @MainActor
    @Test("AchievementLevel(score:) respeta los umbrales")
    func achievementLevelThresholds() {
        let level0 = AchievementLevel(score: 0)
        let level10 = AchievementLevel(score: 10)
        let level119 = AchievementLevel(score: 119)
        let level120 = AchievementLevel(score: 120)
        let level299 = AchievementLevel(score: 299)
        let level300 = AchievementLevel(score: 300)

        #expect(level0 == .none)
        #expect(level10 == .beginner)
        #expect(level119 == .beginner)
        #expect(level120 == .intermediate)
        #expect(level299 == .intermediate)
        #expect(level300 == .advanced)
    }

    @MainActor
    @Test("AchievementLevel expone título e icono coherentes")
    func achievementLevelPresentation() {
        let level = AchievementLevel.advanced

        #expect(level.title == "Avanzado")
        #expect(level.systemImage == "star.circle.fill")
    }

    @Test("La suma de puntos del catálogo alcanza nivel avanzado")
    func catalogTotalPointsReachAdvancedLevel() {
        let totalPoints = AchievementCatalog.all.reduce(0) { $0 + $1.points }
        let level = AchievementLevel(score: totalPoints)

        #expect(totalPoints > 300)
        #expect(level == .advanced)
    }
}
