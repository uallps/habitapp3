import SwiftUI
import SwiftData

struct AppView: Identifiable {
    let id: String
    let title: String
    let icon: String
    let isEnabled: Bool
}

@main
struct HabitApp: App {
    private var storageProvider: StorageProvider
    @State private var selectedDetailView: String?
    let modelContainer: ModelContainer
    
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
    
    private var availableViews: [AppView] {
        [
            AppView(id: "habitos", title: "Hábitos", icon: "checklist", isEnabled: userPreferences.enableHabits),
            AppView(id: "categorias", title: "Categorías", icon: "folder", isEnabled: userPreferences.enableHabits),
            AppView(id: "notas", title: "Notas", icon: "note.text", isEnabled: userPreferences.enableDailyNotes),
            AppView(id: "objetivos", title: "Objetivos", icon: "target", isEnabled: userPreferences.enableGoals),
            AppView(id: "estadisticas", title: "Estadísticas", icon: "chart.bar", isEnabled: userPreferences.enableStatistics),
            AppView(id: "ajustes", title: "Ajustes", icon: "gearshape", isEnabled: true)
        ].filter { $0.isEnabled }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
#if os(iOS)
                TabView {
                    ForEach(availableViews) { view in
                        viewContent(for: view.id)
                            .tabItem { Label(view.title, systemImage: view.icon) }
                    }
                }
#else
                NavigationSplitView {
                    List(selection: $selectedDetailView) {
                        ForEach(availableViews) { view in
                            NavigationLink(value: view.id) {
                                Label(view.title, systemImage: view.icon)
                            }
                        }
                    }
                } detail: {
                    let currentId = selectedDetailView ?? availableViews.first?.id
                    if let currentId {
                        viewContent(for: currentId)
                    } else {
                        Text("Seleccione una opción")
                    }
                }
#endif
            }
            .environmentObject(AppConfig.shared)
            .modelContainer(modelContainer)
            .environmentObject(userPreferences)
            .preferredColorScheme(userPreferences.colorScheme)
            .modifier(AccessibilityFilterModifier(prefs: userPreferences))
            .tint(userPreferences.accentColor)
        }
    }
    
    @ViewBuilder
    private func viewContent(for id: String) -> some View {
        switch id {
        case "habitos": HabitListView(storageProvider: storageProvider)
        case "categorias": CategoryListView(storageProvider: storageProvider)
        case "notas": DailyNotesView(storageProvider: storageProvider)
        case "objetivos": GoalsView(storageProvider: storageProvider)
        case "estadisticas": StatisticsView()
        case "ajustes": SettingsView()
        default: Text("Vista no encontrada")
        }
    }
}
