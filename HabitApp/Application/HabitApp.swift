import SwiftUI
import SwiftData

@main // Punto de entrada

// HabitApp cumple con el protocolo App.
struct HabitApp: App {
    
    private var storageProvider: StorageProvider {
        AppConfig().storageProvider
    }

    @State private var selectedDetailView: String?
    //let modelContainer: ModelContainer
    
    init() {
        // Inicializar el ModelContainer
        //let schema = Schema([Habit.self, DailyNote.self, Goal.self, Milestone.self])
       // let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        //let container: ModelContainer
      //  do {
        //    container = try ModelContainer(for: schema, configurations: [modelConfiguration])
       // } catch {
       //     fatalError("❌ Error inicializando ModelContainer: \(error)")
       // }
        
       // self.modelContainer = container
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
    }
    
    var body: some Scene {
        WindowGroup {
#if os(iOS)
            TabView {
                HabitListView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Hábitos", systemImage: "checklist")
                    }
                CategoryListView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Categorías", systemImage: "folder")
                    }
                DailyNotesView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Notas", systemImage: "note.text")
                    }
                GoalsView(storageProvider: storageProvider)
                    .tabItem {
                        Label("Objetivos", systemImage: "target")
                    }
                 StatisticsView()             
                    .tabItem {
                        Label("Estadísticas", systemImage: "chart.bar")
                    }
                TestReminderView()
                    .tabItem {
                        Label("Test", systemImage: "bell")
                    }
                SettingsView()
                    .tabItem {
                        Label("Ajustes", systemImage: "gearshape")
                    }
            }
            .environmentObject(AppConfig())
           // .modelContainer(modelContainer)  //  AGREGAR ESTO

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
                    .task {
                        storageProvider.resetStorage()
                    }
                    NavigationLink(value: "categorias") {
                        Label("Categorias", systemImage: "folder")
                    }
                    NavigationLink(value: "adicciones") {
                        Label("Adicciones", systemImage: "bandage")
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
            .environmentObject(AppConfig())
           // .modelContainer(modelContainer)  //  AGREGAR ESTO
#endif
        }
    }
}
