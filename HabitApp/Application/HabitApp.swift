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
    
    var body: some Scene {
        WindowGroup{
            #if os(iOS)
            TabView {
                HabitListView()
                    .tabItem {
                        Label("Hábitos", systemImage: "checklist")
                    }
                // TODO: Uncomment when SettingsView exists
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
                    HabitListView(storageProvider: storageProvider)
                case "ajustes":
                    SettingsView()
                default:
                    Text("Seleccione una opción")
                }
            }.environmentObject(AppConfig())
#endif
        }
    }
}
