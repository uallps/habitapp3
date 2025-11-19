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
    
    // Me da igual el tipo de Scene que devuelvas PERO debe de ser siempre un único tipo (No puedes devolver SubScene1 con una lógica y en otra rama lógica SubScene2)
    var body: some Scene {
        // WindowGroup es una struct en Swift (similar a un data class de Kotlin) que cumple con el protocolo Scene.
        // Estás inicializando esa struct. Swift permite la sintaxis de trailing closure, así que si el último parámetro es una función,
        // puedes escribirla fuera de los paréntesis.
        WindowGroup{
#if os(iOS)
            TabView {
                HabitListView(
                    viewModel: HabitListViewModel()
                )
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
                    HabitCategoryView(
                        
                    )
                default:
                    Text("Seleccione una opción")
                }
            }.environmentObject(AppConfig())
#endif
        }
    }
}
