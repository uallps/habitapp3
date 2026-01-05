import SwiftUI

struct AppInitializer: ViewModifier {
    // Obtenemos la configuración del entorno
    @EnvironmentObject private var appConfig: AppConfig
    
    // Estado para asegurar que solo se registre una vez
    @State private var hasInitialized = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                // Si ya se inicializó, no hacemos nada
                guard !hasInitialized else { return }
                
                let provider = appConfig.storageProvider
                let registry = PluginRegistry.shared
                
                // --- REGISTRO DE PLUGINS ---
                // Aquí conectamos todos los plugins al PluginRegistry
                registry.register(plugin: ReminderPlugin())
                registry.register(plugin: HabitGoalPlugin(storageProvider: provider))
                registry.register(plugin: StreakPlugin(storageProvider: provider))
                
                print("🚀 AppInitializer: Plugins registrados correctamente en el Registro")
                
                hasInitialized = true
            }
    }
}

// Extensión para que sea fácil de usar en HabitApp.swift
extension View {
    func setupApp() -> some View {
        self.modifier(AppInitializer())
    }
}
