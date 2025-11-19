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
    
    // Body es una propiedad calculada, es decir, una propiedad cuyo valor se calcula al ejecutar la app en lugar de almacenarse directamente.
    // Así, cuando la app intenta leer body, en vez de leer un valor previo, este se calcula. Una propiedad calculada es cualquier propiedad que,
    // en lugar de ir seguida de un "=", va seguida de { }. Las palabras clave posteriores representan el tipo de retorno.

    // Some Scene es la característica de tipos opacos de Swift. Básicamente significa: “body devolverá un tipo específico que cumple con Scene,
    // pero no quiero exponer el tipo concreto aquí."
    var body: some Scene {
        // WindowGroup es una struct en Swift (similar a un data class de Kotlin) que cumple con el protocolo Scene.
        // Estás inicializando esa struct. Swift permite la sintaxis de trailing closure, así que si el último parámetro es una función,
        // puedes escribirla fuera de los paréntesis.
        WindowGroup{
#if os(iOS)
            TabView {
                HabitListView()
                // Sistema de modificadores con punto (SwiftUI), estilo DSL
                    .tabItem {
                        Label("Hábitos", systemImage: "checklist")
                    }
                // TODO: Descomentar cuando exista SettingsView
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
