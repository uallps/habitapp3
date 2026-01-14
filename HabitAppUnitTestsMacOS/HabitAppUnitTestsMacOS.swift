import Testing
import Foundation

@testable import HabitApp

struct HabitAppUnitTestsMacOS {
    
    // MARK: - DailyNotes Tests
    
    @Test func createAndUpdateDailyNote() async throws {
        let note = DailyNote(
            title: "Test Note",
            content: "Test content",
            date: Date()
        )
        
        #expect(note.title == "Test Note")
        #expect(note.content == "Test content")
        #expect(note.id != UUID())
        
        note.updateContent(title: "Updated Title", content: "Updated content")
        
        #expect(note.title == "Updated Title")
        #expect(note.content == "Updated content")
        #expect(note.updatedAt > note.createdAt)
    }
    
    @Test func dailyNoteWithHabitId() async throws {
        let habitId = UUID()
        let note = DailyNote(
            title: "Habit Note",
            content: "Note for habit",
            date: Date(),
            habitId: habitId
        )
        
        #expect(note.habitId == habitId)
        #expect(note.title == "Habit Note")
    }
    
    // MARK: - Goals Tests
    
    @Test func createGoalWithProgress() async throws {
        let targetDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        let goal = Goal(
            title: "Exercise 30 days",
            description: "Exercise daily for 30 days",
            targetCount: 30,
            targetDate: targetDate
        )
        
        #expect(goal.title == "Exercise 30 days")
        #expect(goal.targetCount == 30)
        #expect(goal.currentCount == 0)
        #expect(goal.isCompleted == false)
        #expect(goal.progress == 0.0)
    }
    
    @Test func trackGoalProgress() async throws {
        let targetDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        
        let goal = Goal(
            title: "Read 10 books",
            description: "Complete 10 books this month",
            targetCount: 10,
            targetDate: targetDate
        )
        
        goal.updateProgress(count: 5)
        #expect(goal.currentCount == 5)
        #expect(goal.progress == 0.5)
        
        goal.updateProgress(count: 10)
        #expect(goal.currentCount == 10)
        #expect(goal.progress == 1.0)
    }
    
    @Test func goalWithMilestones() async throws {
        let targetDate = Calendar.current.date(byAdding: .day, value: 90, to: Date())!
        
        let goal = Goal(
            title: "Save money",
            description: "Save $1000",
            targetCount: 1000,
            targetDate: targetDate
        )
        
        let milestone1 = Milestone(title: "First $250", targetValue: 250, goal: goal)
        let milestone2 = Milestone(title: "Half $500", targetValue: 500, goal: goal)
        
        goal.milestones.append(milestone1)
        goal.milestones.append(milestone2)
        
        #expect(goal.milestones.count == 2)
        #expect(milestone1.targetValue == 250)
        #expect(milestone2.targetValue == 500)
    }
    
    @Test func goalDaysRemaining() async throws {
        let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        
        let goal = Goal(
            title: "Weekly challenge",
            description: "Complete in 7 days",
            targetCount: 7,
            targetDate: futureDate
        )
        
        #expect(goal.daysRemaining >= 6) // Allow for time variation
        #expect(goal.daysRemaining <= 7)
    }
    


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
}