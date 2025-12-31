//
//  AppInitializer.swift
//  HabitApp
//
//  Created by Aula03 on 10/12/25.
//

import SwiftUI
import SwiftData

struct AppInitializer: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Registramos los plugins SOLO una vez
                let habitGoalPlugin = HabitGoalPlugin(context: modelContext)
                let reminderPlugin = ReminderPlugin()
                let streakPlugin = StreakPlugin(context: modelContext)
                
                TaskDataObserverManager.shared.register(habitGoalPlugin)
                TaskDataObserverManager.shared.register(reminderPlugin)
                TaskDataObserverManager.shared.register(streakPlugin)
                print("🔔 Plugins registrados: HabitGoal, Reminder y Streaks")
            }
    }
}

extension View {
    func setupApp() -> some View {
        self.modifier(AppInitializer())
    }
}
