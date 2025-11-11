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
    
    var body: some Scene {
        WindowGroup{
#if os(iOS)
            TabView {
                HabitListView()
                    .tabItem {
                        Label("Hábitos", systemImage: "checklist")
                    }
                DailyNotesView()
                    .tabItem {
                        Label("Notas", systemImage: "note.text")
                    }
                // TODO: Uncomment when SettingsView exists
                // SettingsView()
                //     .tabItem {
                //         Label("Ajustes", systemImage: "gearshape")
                //     }
            }
            .environmentObject(AppConfig())
#else
            NavigationSplitView {
                List(selection: $selectedDetailView) {
                    NavigationLink(value: "habitos") {
                        Label("Habitos", systemImage: "checklist")
                    }
                    NavigationLink(value: "notas") {
                        Label("Notas Diarias", systemImage: "note.text")
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
                    // TODO: case "ajustes":
                    // TODO: SettingsView()
                default:
                    Text("Seleccione una opción")
                }
            }.environmentObject(AppConfig())
#endif
        }
        .modelContainer(for: [DailyNote.self])
    }
}
