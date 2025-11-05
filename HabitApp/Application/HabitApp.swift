//
//  HabitAppApp.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import SwiftUI

@main
struct TaskApp: App {
    @State private var selectedDetailView: String?
    
    var body: some Scene {
        WindowGroup{
#if os(iOS)
            TabView {
                TaskListView()
                    .tabItem {
                        Label("Hábitos", systemImage: "checklist")
                    }
                SettingsView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
            }
            .environmentObject(AppConfig())
#else
            NavigationSplitView {
                List(selection: $selectedDetailView) {
                    NavigationLink(value: "habitos") {
                        Label("Habitos", systemImage: "checklist")
                    }
                    NavigationLink(value: "ajustes") {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
            } detail: {
                switch selectedDetailView {
                case "habitos":
                    TaskListView()
                //TODO: case "ajustes":
                    //TODO: SettingsView()
                default:
                    Text("Seleccione una opción")
                }
            }.environmentObject(AppConfig())
#endif
        WindowGroup {
            HabitListView()
        }
    }
}
