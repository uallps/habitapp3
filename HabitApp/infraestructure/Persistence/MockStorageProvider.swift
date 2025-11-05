//
//  MockStorageProvider.swift
//  HabitApp
//
//  Created by Aula03 on 5/11/25.
//

class MockStorageProvider: StorageProvider {
    private var storedHabits: [Habit] = [
        Habit(title: "Mock Habit 1"),
        Habit(title: "Mock Habit 2", isCompleted: true)
    ]
    
    func loadHabits() async throws -> [Habit] {
        return storedHabits
    }
    
    func saveHabits(habits: [Habit]) async throws {
        storedHabits = habits
    }
}
