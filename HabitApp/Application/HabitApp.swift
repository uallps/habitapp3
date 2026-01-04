import SwiftUI
import SwiftData

@main // Punto de entrada

// HabitApp cumple con el protocolo App.
struct HabitApp: App {
    
    private var storageProvider: StorageProvider {
        AppConfig().storageProvider
    }

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
        WindowGroup {
#if os(iOS)
            TabView {
                // TAB 1: Hábitos
                NavigationStack {
                    HabitListView(
                        viewModel: HabitListViewModel(
                            storageProvider: storageProvider
                        )
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
                NavigationStack {
                    TestReminderView()
                }
                .tabItem {
                    Label("Test Notificaciones", systemImage: "bell")
                }
                // TAB 4: Ajustes (placeholder)
                NavigationStack {
                    Text("Ajustes (próximamente)")
                }
                //.task {
                //    storageProvider.resetStorage()
                //}
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape")
                }
                
                // Tab 3: Categorías
                NavigationStack {
                    CategoryListView(
                            storageProvider: storageProvider
                        )
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
                    NavigationLink(value: "notas") {
                        Label("Notas Diarias", systemImage: "note.text")
                    }
                    NavigationLink(value: "ajustes") {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                    //.task {
                    //    storageProvider.resetStorage()
                    //}
                    NavigationLink(value: "categorias") {
                        Label("Categorias", systemImage: "folder")
                    }
                }
            } detail: {
                switch selectedDetailView {
                case "habitos":
                    HabitListView(
                        viewModel: HabitListViewModel(
                            storageProvider: storageProvider
                        )
                    )
                // TODO: case "ajustes":
                // TODO: SettingsView()
                case "categorias":
                    CategoryListView(
                        storageProvider: storageProvider
                    )
                case "notas":
                    DailyNotesView()
                    // TODO: case "ajustes":
                    // TODO: SettingsView()
                default:
                    Text("Seleccione una opción")
                }
            }
            .environmentObject(AppConfig())
#endif
        }
        // Register all @Model types here
        .modelContainer(for: [
            DailyNote.self,
            Habit.self,
            Category.self,
            UserImageSlot.self
        ])
    }
}
