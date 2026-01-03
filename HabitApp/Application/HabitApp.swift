//
//  HabitAppApp.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import SwiftUI

@main
struct HabitApp: App {
    @State private var selectedDetailView: String?
    @StateObject private var appConfig = AppConfig()
    
    private var storageProvider: StorageProvider {
        appConfig.storageProvider
    }
    
    init() {
        #if os(iOS)
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("Permiso concedido para notificaciones")
            } else if let error = error {
                print("Error solicitando permisos: \(error)")
            }
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup{
#if os(iOS)
            TabView {
                HabitListView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Hábitos", systemImage: "checklist")
                    }
                DailyNotesView()
                    .tabItem {
                        Label("Notas", systemImage: "note.text")
                    }
                GoalsView()
                    .tabItem {
                        Label("Objetivos", systemImage: "target")
                    }
                TestReminderView()
                    .tabItem {
                        Label("Test", systemImage: "bell")
                    }
                SettingsView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
            }
            .environmentObject(appConfig)

#else
            NavigationSplitView {
                List(selection: $selectedDetailView) {
                    NavigationLink(value: "habitos") {
                        Label("Habitos", systemImage: "checklist")
                    }
                    NavigationLink(value: "notas") {
                        Label("Notas Diarias", systemImage: "note.text")
                    }
                    NavigationLink(value: "rachas") {
                        Label("Rachas", systemImage: "flame")
                    }
                    NavigationLink(value: "objetivos") {
                        Label("Objetivos", systemImage: "target")
                    }
                    NavigationLink(value: "ajustes") {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
            } detail: {
                switch selectedDetailView {
                case "habitos":
                    HabitListView(storageProvider: storageProvider)
                case "notas":
                    DailyNotesView()
                case "objetivos":
                    GoalsView()
                case "ajustes":
                    SettingsView()
                default:
                    Text("Seleccione una opción")
                }
            }.environmentObject(appConfig)
#endif
        }
    }
}
