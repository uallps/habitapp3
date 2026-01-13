import SwiftUI
import SwiftData

@main
struct HabitApp: App {
    private var storageProvider: StorageProvider
    @State private var selectedDetailView: String?
    let modelContainer: ModelContainer
    
    // 1. Instanciamos las preferencias (donde vive la lógica del tema)
    @StateObject private var userPreferences = UserPreferences()
    
    init() {
        let appConfig = AppConfig.shared
        self.storageProvider = appConfig.storageProvider
        guard let swiftDataProvider = storageProvider as? SwiftDataStorageProvider else {
            fatalError("StorageProvider is not a SwiftDataStorageProvider")
        }
        self.modelContainer = swiftDataProvider.modelContainer
        
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
            // 2. Usamos un Group para aplicar los modificadores a toda la App a la vez
            Group {
#if os(iOS)
                TabView {
                    HabitListView(storageProvider: storageProvider)
                        .tabItem { Label("Hábitos", systemImage: "checklist") }
                    
                    CategoryListView(storageProvider: storageProvider)
                        .tabItem { Label("Categorías", systemImage: "folder") }
                    
                    DailyNotesView(storageProvider: storageProvider)
                        .tabItem { Label("Notas", systemImage: "note.text") }
                    
                    GoalsView(storageProvider: storageProvider)
                        .tabItem { Label("Objetivos", systemImage: "target") }
                    
                    StatisticsView()
                        .tabItem { Label("Estadísticas", systemImage: "chart.bar") }
                    
                    SettingsView()
                        .tabItem { Label("Ajustes", systemImage: "gearshape") }
                    
                    AddictionListView(storageProvider: storageProvider)
                        .tabItem { Label("Adicciones", systemImage: "bandage") }
                }
#else
                NavigationSplitView {
                    List(selection: $selectedDetailView) {
                        NavigationLink(value: "habitos") { Label("Habitos", systemImage: "checklist") }
                        NavigationLink(value: "notas") { Label("Notas Diarias", systemImage: "note.text") }
                        NavigationLink(value: "objetivos") { Label("Objetivos", systemImage: "target") }
                        NavigationLink(value: "estadisticas") { Label("Estadísticas", systemImage: "chart.bar") }
                        NavigationLink(value: "ajustes") { Label("Ajustes", systemImage: "gearshape") }
                        NavigationLink(value: "categorias") { Label("Categorias", systemImage: "folder") }
                        NavigationLink(value: "adicciones") { Label("Adicciones", systemImage: "bandage") }
                    }
                } detail: {
                    switch selectedDetailView {
                    case "habitos": HabitListView(storageProvider: storageProvider)
                    case "notas": DailyNotesView(storageProvider: storageProvider)
                    case "objetivos": GoalsView(storageProvider: storageProvider)
                    case "estadisticas": StatisticsView()
                    case "ajustes": SettingsView()
                    case "categorias": CategoryListView(storageProvider: storageProvider)
                    case "adicciones": AddictionListView(storageProvider: storageProvider)
                    default: Text("Seleccione una opción")
                    }
                }
#endif
            }
            // --- MODIFICADORES GLOBALES ---
            .environmentObject(AppConfig.shared)
            .modelContainer(modelContainer)
            .environmentObject(userPreferences)
            .preferredColorScheme(userPreferences.colorScheme)
            .modifier(AccessibilityFilterModifier(prefs: userPreferences))
            .tint(userPreferences.accentColor)
        }
    }
}
