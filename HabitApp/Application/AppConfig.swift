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

    // MARK: - Storage Provider
    
    private lazy var swiftDataProvider: SwiftDataStorageProvider = {
        let schemas: [any PersistentModel.Type] = [Habit.self, DailyNote.self, Goal.self, Milestone.self]
        let schema = Schema(schemas)
        print("📦 Schemas registrados: \(schemas)")
        return SwiftDataStorageProvider(schema: schema)
    }()

    var storageProvider: StorageProvider {
        switch storageType {
        case .swiftData:
            return swiftDataProvider
        }
    }
}

enum StorageType: String, CaseIterable, Identifiable {
    case swiftData = "SwiftData Storage"

    var id: String { self.rawValue }
}