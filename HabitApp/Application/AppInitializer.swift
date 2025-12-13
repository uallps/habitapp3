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
                // Registramos el plugin SOLO una vez
                let plugin = HabitGoalPlugin(context: modelContext)
                TaskDataObserverManager.shared.register(plugin)
            }
    }
}

extension View {
    func setupApp() -> some View {
        self.modifier(AppInitializer())
    }
}
