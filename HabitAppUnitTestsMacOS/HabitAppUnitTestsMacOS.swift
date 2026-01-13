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
    
}
