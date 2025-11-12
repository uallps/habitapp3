
//  HabitListViewModel.swift
//  HabitApp
//
//

import Foundation
import Combine
import SwiftUI

class HabitListViewModel: ObservableObject {
    private let storageProvider: StorageProvider

    init(storageProvider: StorageProvider = SwiftDataStorageProvider()) {
        self.storageProvider = storageProvider
    }

    @Published var habits: [Habit] = [
        Habit(title: "Comprar leche", dueDate: Date().addingTimeInterval(86400)),
        Habit(title: "Hacer ejercicio", priority: .high),
        Habit(title: "Llamar a mamá")
    ]

    func loadHabits() async {
        do {
            habits = try await storageProvider.loadHabits()
        } catch {
            print("Error loading habits: \(error)")
        }
    }

    func addHabit(habit: Habit) async {
        habits.append(habit)
        try? await storageProvider.saveHabits(habits: habits)
    }

    func removeHabits(atOffsets offsets: IndexSet) async {
        habits.remove(atOffsets: offsets)
        try? await storageProvider.saveHabits(habits: habits)
    }

    func toggleCompletion(habit: Habit) async {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
            try? await storageProvider.saveHabits(habits: habits)
        }
    }

    func saveHabits() async {
        try? await storageProvider.saveHabits(habits: habits)
    }

}
