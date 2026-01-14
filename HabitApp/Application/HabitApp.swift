import SwiftUI
import SwiftData

@main // Punto de entrada

// HabitApp cumple con el protocolo App.
struct HabitApp: App {
    
    private var storageProvider: StorageProvider

    @State private var selectedDetailView: String?
    
    // Necesario para Query
    let modelContainer: ModelContainer
    
    @StateObject private var userPreferences = UserPreferences()
    private let appConfig: AppConfig  // UNA SOLA INSTANCIA (no StateObject porque init necesita storageProvider)
    
    init() {
        print("\n🚀 ==================== INICIO HABITAPP ====================")
        
        // Crear UNA SOLA instancia de AppConfig
        self.appConfig = AppConfig()
        self.storageProvider = appConfig.storageProvider
        
        guard let swiftDataProvider = storageProvider as? SwiftDataStorageProvider else {
            fatalError("StorageProvider is not a SwiftDataStorageProvider")
        }
        self.modelContainer = swiftDataProvider.modelContainer
        
        print("📦 ModelContainer inicializado correctamente")
        print("🎯 StorageProvider: SwiftDataStorageProvider")
        
        //self._appConfig = StateObject(wrappedValue: AppConfig(modelContainer: container))
        
        #if os(iOS)
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                print("✅ Permiso concedido para notificaciones")
            } else if let error = error {
                print("❌ Error solicitando permisos: \(error)")
            }
        }
        #endif
        
        print("🏁 ==================== HABITAPP LISTO ====================\n")
    }
    
    var body: some Scene {
        WindowGroup {
#if os(iOS)
            TabView {
                HabitListView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Hábitos", systemImage: "checklist")
                    }
                StatisticsView()             
                    .tabItem {
                        Label("Estadísticas", systemImage: "chart.bar")
                    }
                AchievementsListView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Logros", systemImage: "trophy.fill")
                    }
                SettingsView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
            }
            .environmentObject(appConfig)  // Usar la misma instancia
            .modelContainer(modelContainer)  //  AGREGAR ESTO
            .environmentObject(userPreferences)

#else
            NavigationSplitView {
                List(selection: $selectedDetailView) {
                    NavigationLink(value: "habitos") {
                        Label("Habitos", systemImage: "checklist")
                    }
                    NavigationLink(value: "estadisticas") {
                        Label("Estadísticas", systemImage: "chart.bar")
                    }
                    NavigationLink(value: "logros") {
                        Label("Logros", systemImage: "trophy.fill")
                    }
                    NavigationLink(value: "ajustes") {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
            } detail: {
                switch selectedDetailView {
                case "habitos":
                    HabitListView(storageProvider: storageProvider)
                case "estadisticas":
                    StatisticsView()
                case "logros":
                    AchievementsListView(storageProvider: storageProvider)
                case "ajustes":
                    SettingsView()
                default:
                    Text("Seleccione una opción")
                }
            }
            .environmentObject(appConfig)  // Usar la misma instancia
            .modelContainer(modelContainer)
            .environmentObject(userPreferences)
#endif
        }
    }
}
