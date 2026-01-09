import SwiftUI
import SwiftData
import Combine
import SwiftData

class AppConfig: ObservableObject {
        
        // MARK: - Plugin Management
        private var plugins: [FeaturePlugin] = []
        
        // MARK: - Storage Provider
        
        private lazy var swiftDataStorageProvider: SwiftDataStorageProvider = {
            // Obtener modelos base
            var schemas: [any PersistentModel.Type] = [Habit.self, Category.self]
            
            // Agregar modelos de plugins habilitados
            schemas.append(contentsOf: PluginRegistry.shared.getEnabledModels(from: plugins))
            
            let schema = Schema(schemas)
            print("📦 Schemas registrados: \(schemas)")
            print("🔌 Plugins activos: \(plugins.filter { $0.isEnabled }.count)/\(plugins.count)")
            
            return SwiftDataStorageProvider(schema: schema)
        }()
        
        var storageProvider: StorageProvider {
            switch storageType {
            case .swiftData:
                return swiftDataStorageProvider
                //case .json:
                //   return JSONStorageProvider.shared
            }
        }
        
        @AppStorage("storageType")
        var storageType: StorageType = .swiftData
        
        @AppStorage("showCategories")
        static var showCategories: Bool = true
        @AppStorage("showDueDates")
        static var showDueDates: Bool = true
        
        @AppStorage("showPriorities")
        static var showPriorities: Bool = true
        
        @AppStorage("enableReminders")
        static var enableReminders: Bool = true
    
        @AppStorage("showGoals")
        static var enableGoals: Bool = true

    init() {
        // Descubrir y registrar plugins automáticamente
        let discoveredPlugins = PluginDiscovery.discoverPlugins()
        for pluginType in discoveredPlugins {
            PluginRegistry.shared.register(pluginType)
        }
        
        print("📝 Plugins registrados en AppConfig: \(PluginRegistry.shared.count)")
        
        // Crear instancias de los plugins
        self.plugins = PluginRegistry.shared.createPluginInstances(config: self)
    }
    
   // private let modelContainer: ModelContainer
    
    //init(modelContainer: ModelContainer) {
     //   self.modelContainer = modelContainer
       // setupPlugins()
    //}
    
    // private func setupPlugins() {
    //     let registry = PluginRegistry.shared
        
    //     //  Registrar los plugins
    //     registry.register(ReminderPlugin.Type)
    //     registry.register(HabitGoalPlugin.Type)
        
    //     print("✅ Plugins registrados correctamente")
    // }
    
    // MARK: - Storage Provider
    
    //private lazy var swiftDataProvider: SwiftDataStorageProvider = {
     //   return SwiftDataStorageProvider(modelContainer: modelContainer)
   // }()
    

    enum StorageType: String, CaseIterable, Identifiable {
        case swiftData = "SwiftDataStorage"
        //case json = "JSONStorage"
        
        var id: String { self.rawValue }
    }
}
