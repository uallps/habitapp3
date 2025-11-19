//
//  HabitAppApp.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import SwiftUI

@main // Punto de entrada

// HabitApp cumple con el protocolo App.
struct HabitApp: App {
    @State private var selectedDetailView: String?
    
    var body: some Scene {
        WindowGroup {
#if os(iOS)
            TabView {
                // Tab 1: Hábitos
                NavigationStack {
                    HabitListView(
                        viewModel: HabitListViewModel()
                    )
                }
                .tabItem {
                    Label("Hábitos", systemImage: "checklist")
                }
                
                // Tab 2: Ajustes (placeholder until you add SettingsView)
                NavigationStack {
                    Text("Ajustes (próximamente)")
                }
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape")
                }
                
                // Tab 3: Categorías
                NavigationStack {
                    HabitCategoryView()
                }
                .tabItem {
                    Label("Categorías", systemImage: "folder")
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
                    NavigationLink(value: "categorias") {
                        Label("Categorias", systemImage: "folder")
                    }
                }
            } detail: {
                switch selectedDetailView {
                case "habitos":
                    HabitListView(viewModel: HabitListViewModel())
                // TODO: case "ajustes":
                // TODO: SettingsView()
                case "categorias":
                    HabitCategoryView()
                default:
                    Text("Seleccione una opción")
                }
            }
            .environmentObject(AppConfig())
#endif
        }
    }
}
