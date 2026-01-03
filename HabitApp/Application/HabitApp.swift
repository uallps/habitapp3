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
    
    private var storageProvider: StorageProvider {
        AppConfig().storageProvider
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
                NavigationStack {
                    HabitListView(
                        viewModel: HabitListViewModel()
                    )
                }
                .tabItem {
                    Label("Hábitos", systemImage: "checklist")
                }

                NavigationStack {
                    DailyNotesView()
                }
                .tabItem {
                    Label("Notas", systemImage: "note.text")
                }
                
                NavigationStack {
                    GoalsView()
                }
                .tabItem {
                    Label("Objetivos", systemImage: "target")
                }
                
                NavigationStack {
                    TestReminderView()
                }
                .tabItem {
                    Label("Test", systemImage: "bell")
                }
                
                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape")
                }
            }
            .environmentObject(AppConfig())
            .environment(\.modelContext, (storageProvider as! SwiftDataStorageProvider).context)

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
                    HabitListView(viewModel: HabitListViewModel())
                case "notas":
                    DailyNotesView()
                case "objetivos":
                    GoalsView()
                case "ajustes":
                    SettingsView()
                default:
                    Text("Seleccione una opción")
                }
            }.environmentObject(AppConfig())
            .environment(\.modelContext, (storageProvider as! SwiftDataStorageProvider).context)
            .setupApp()
#endif
        }
    }
}
