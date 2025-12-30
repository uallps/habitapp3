//
//  StreaksViewModel.swift
//  HabitApp
//
//  Created by Aula03 on 30/12/25.
//


import Foundation
import SwiftData
import Combine

final class StreaksViewModel: ObservableObject {
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    /// Incrementa la racha de un hábito específico
    func markHabitAsCompleted(_ habit: Habit) {
        guard let modelContext else { return }
        
        // Si el hábito no tiene objeto racha, lo creamos
        if habit.streak == nil {
            let newStreak = Streak()
            newStreak.habit = habit
            habit.streak = newStreak
            modelContext.insert(newStreak)
        }
        
        habit.streak?.update(completionDate: Date())
        saveContext()
    }

    /// Verifica si una racha debe resetearse a 0 porque han pasado más de 24h
    func refreshStreaks(for habits: [Habit]) {
        let calendar = Calendar.current
        let today = Date()
        
        for habit in habits {
            guard let streak = habit.streak, let lastDate = streak.lastCompletionDate else { continue }
            
            let diff = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: today))
            
            // Si ha pasado más de un día desde la última vez (y no es hoy), reset
            if let days = diff.day, days > 1 {
                streak.currentCount = 0
                saveContext()
            }
        }
    }

    private func saveContext() {
        try? modelContext?.save()
    }
}