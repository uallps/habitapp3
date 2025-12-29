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
                
                TaskDataObserverManager.shared.register(habitGoalPlugin)
                TaskDataObserverManager.shared.register(reminderPlugin)
                
                print("🔔 Plugins registrados: HabitGoal y Reminder")
            }
    }
}

extension View {
    func setupApp() -> some View {
        self.modifier(AppInitializer())
    }
}
