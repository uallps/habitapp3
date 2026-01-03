//
//  HabitAppApp.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import SwiftUI
import SwiftData

@main
struct HabitApp: App {
    @State private var selectedDetailView: String?
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
                // TAB 1: Hábitos
                NavigationStack {
                    HabitListView(
                        viewModel: HabitListViewModel()
                    )
                }
                .tabItem {
                    Label("Hábitos", systemImage: "checklist")
                }

                // TAB 2: Notas Diarias
                NavigationStack {
                    DailyNotesView()
                }
                .tabItem {
                    Label("Notas", systemImage: "note.text")
                }
                
                // TAB 3: Estadísticas
                NavigationStack {
                    StatisticsView()
                }
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar")
                }
                
                // TAB 4: Objetivos
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
                // TAB 5: Ajustes
                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape")
                }
            }
            .environmentObject(AppConfig())
            .setupApp()    

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
#endif
        }
        .modelContainer(for: [DailyNote.self, Habit.self, Goal.self, Milestone.self])
    }
}
