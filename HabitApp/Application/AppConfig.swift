//
//  AppConfig.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//
import SwiftUI
import SwiftData
import Combine

class AppConfig: ObservableObject {
    @AppStorage("showDueDates")
    static var showDueDates: Bool = true

    @AppStorage("showPriorities")
    static var showPriorities: Bool = true

    @AppStorage("enableReminders")
    static var enableReminders: Bool = true

    @AppStorage("storageType")
    var storageType: StorageType = .swiftData

    init() {
        setupPlugins()
    }
    
    private func setupPlugins() {
        let registry = PluginRegistry.shared
        
        // ⭐ Registrar los plugins
        registry.register(plugin: ReminderPlugin())
        registry.register(plugin: HabitGoalPlugin(storageProvider: storageProvider))
        
        print("✅ Plugins registrados correctamente")
    }

    // MARK: - Storage Provider
    
    private lazy var swiftDataProvider: SwiftDataStorageProvider = {
        return SwiftDataStorageProvider(schema: schema)
    }()

    var storageProvider: StorageProvider {
        return swiftDataProvider
    }
    
    var schema: Schema {
        Schema([Habit.self, DailyNote.self, Goal.self, Milestone.self])
    }
}

enum StorageType: String, CaseIterable, Identifiable {
    case swiftData = "SwiftData Storage"

    var id: String { self.rawValue }
}