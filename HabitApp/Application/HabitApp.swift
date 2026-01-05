
import SwiftUI
import SwiftData

@main
struct HabitApp: App {
    // 1. Estados de navegación y configuración
    @State private var selectedDetailView: String? = "habitos"
    @StateObject private var appConfig = AppConfig()
    
    // 2. Contenedor de SwiftData
    let modelContainer: ModelContainer
    
    // Propiedad para acceder al provider definido en AppConfig
    private var storageProvider: StorageProvider {
        appConfig.storageProvider
    }
    
    init() {
        // Configuración del esquema con todos los modelos de la app
        let schema = Schema([
            Habit.self,
            DailyNote.self,
            Goal.self,
            Milestone.self,
            Streak.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ ModelContainer inicializado con éxito")
        } catch {
            fatalError("❌ Error al inicializar ModelContainer: \(error.localizedDescription)")
        }
        
        // Permisos de notificaciones (solo iOS)
        #if os(iOS)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("✅ Permisos de notificación concedidos")
            }
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                #if os(iOS)
                // --- DISEÑO PARA IPHONE (TABS) ---
                TabView {
                    HabitListView(storageProvider: storageProvider)
                        .tabItem {
                            Label("Hábitos", systemImage: "checklist")
                        }
                    
                    DailyNotesView()
                        .tabItem {
                            Label("Notas", systemImage: "note.text")
                        }
                    
                    NavigationStack {
                        StatisticsView()
                    }
                    .tabItem {
                        Label("Estadísticas", systemImage: "chart.bar")
                    }
                    
                    GoalsView()
                        .tabItem {
                            Label("Objetivos", systemImage: "target")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Label("Ajustes", systemImage: "gearshape")
                        }
                }
                #else
                // --- DISEÑO PARA IPAD / MACOS (SIDEBAR) ---
                NavigationSplitView {
                    List(selection: $selectedDetailView) {
                        NavigationLink(value: "habitos") {
                            Label("Hábitos", systemImage: "checklist")
                        }
                        NavigationLink(value: "notas") {
                            Label("Notas Diarias", systemImage: "note.text")
                        }
                        NavigationLink(value: "rachas") {
                            Label("Rachas/Estadísticas", systemImage: "flame")
                        }
                        NavigationLink(value: "objetivos") {
                            Label("Objetivos", systemImage: "target")
                        }
                        NavigationLink(value: "ajustes") {
                            Label("Ajustes", systemImage: "gearshape")
                        }
                    }
                    .navigationTitle("HabitApp")
                } detail: {
                    switch selectedDetailView {
                    case "habitos":
                        HabitListView(storageProvider: storageProvider)
                    case "notas":
                        DailyNotesView()
                    case "rachas":
                        StatisticsView()
                    case "objetivos":
                        GoalsView()
                    case "ajustes":
                        SettingsView()
                    default:
                        Text("Selecciona una opción en el menú lateral")
                            .foregroundStyle(.secondary)
                    }
                }
                #endif
            }
            // --- MODIFICADORES GLOBALES (El orden es la clave) ---
            .modelContainer(modelContainer)    // 1. Provee el contexto de base de datos
            .setupApp()                        // 2. Ejecuta el AppInitializer (busca appConfig)
            .environmentObject(appConfig)      // 3. Envuelve todo lo anterior con el objeto config
        }
    }
}