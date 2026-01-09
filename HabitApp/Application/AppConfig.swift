//
//  AppConfig.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//
import SwiftUI
import SwiftData

// Responsabilidad: composición de dependencias (persistencia, plugins).
final class AppDependencies: ObservableObject {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        setupPlugins()
    }
    
    private func setupPlugins() {
        let registry = PluginRegistry.shared
        registry.register(plugin: HabitGoalPlugin(storageProvider: storageProvider))
        registry.register(plugin: StreakPlugin(storageProvider: storageProvider))
        print("✅ Plugins registrados correctamente")
    }

    // MARK: - Storage Provider
    private lazy var swiftDataProvider: SwiftDataStorageProvider = {
        SwiftDataStorageProvider(modelContainer: modelContainer)
    }()

    var storageProvider: StorageProvider { swiftDataProvider }
}
