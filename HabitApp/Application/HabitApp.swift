import SwiftUI
import SwiftData

@main
struct HabitApp: App {
    @State private var selectedDetailView: String?
    let modelContainer: ModelContainer
    @StateObject private var appConfig: AppConfig
    
    private var storageProvider: StorageProvider {
        appConfig.storageProvider
    }
    
    init() {
        // Inicializar el ModelContainer
        let schema = Schema([Habit.self, DailyNote.self, Goal.self, Milestone.self,Streak.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("❌ Error inicializando ModelContainer: \(error)")
        }
        
        self.modelContainer = container
        self._appConfig = StateObject(wrappedValue: AppConfig(modelContainer: container))
        
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
    }
    
    var body: some Scene {
        WindowGroup{
#if os(iOS)
            TabView {
                HabitListView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Hábitos", systemImage: "checklist")
                    }
                DailyNotesView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Notas", systemImage: "note.text")
                    }
                GoalsView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Objetivos", systemImage: "target")
                    }
                StatisticsView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Estadísticas", systemImage: "chart.bar")
                    }

                SettingsView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
            }
            .environmentObject(appConfig)
            .modelContainer(modelContainer)  //  AGREGAR ESTO

#else
            NavigationSplitView {
                List(selection: $selectedDetailView) {
                    NavigationLink(value: "habitos") {
                        Label("Habitos", systemImage: "checklist")
                    }
                    NavigationLink(value: "notas") {
                        Label("Notas Diarias", systemImage: "note.text")
                    }
                    NavigationLink(value: "rachas") {
                        Label("Rachas", systemImage: "flame")
                    }
                    NavigationLink(value: "objetivos") {
                        Label("Objetivos", systemImage: "target")
                    }
                    NavigationLink(value: "ajustes") {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
            } detail: {
                switch selectedDetailView {
                case "habitos":
                    HabitListView(storageProvider: storageProvider)
                case "notas":
                    DailyNotesView(storageProvider: storageProvider)
                case "objetivos":
                    GoalsView(storageProvider: storageProvider)
                case "ajustes":
                    SettingsView()
                default:
                    Text("Seleccione una opción")
                }
            }
            .environmentObject(appConfig)
            .modelContainer(modelContainer)  //  AGREGAR ESTO
#endif
        }
    }
}
