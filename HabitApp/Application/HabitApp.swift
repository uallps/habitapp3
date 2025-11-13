//
//  HabitAppApp.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import SwiftUI

@main // Entrypoint

// HabitApp conforms App protocol.
struct HabitApp: App {
    @State private var selectedDetailView: String?
    
    // Body is a computed property, this is, a property which value is calculated when running the app instead of being stored directly. So, when the
    // app tries to read body instead of reading the previous value, it's calculated. A computed property is any property that instead of being followed by a
    // "=" is followed by { } the next keywords represent the return type.

    // Some scene is Swift's opaque type feature. It's basically: “body will return a specific type that conforms to Scene, but I don’t want to expose the concrete type here."
    var body: some Scene {
        WindowGroup{
#if os(iOS)
            TabView {
                HabitListView()
                    .tabItem {
                        Label("Hábitos", systemImage: "checklist")
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
                    NavigationLink(value: "ajustes") {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
            } detail: {
                switch selectedDetailView {
                case "habitos":
                    HabitListView(viewModel: HabitListViewModel())
                    // TODO: case "ajustes":
                    // TODO: SettingsView()
                default:
                    Text("Seleccione una opción")
                }
            }.environmentObject(AppConfig())
#endif
        }
    }
}
