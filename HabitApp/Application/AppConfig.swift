import SwiftUI
import SwiftData
import Combine
import SwiftData

class AppConfig: ObservableObject {
        
        // MARK: - Plugin Management
        private var plugins: [FeaturePlugin] = []
        var userPreferences: UserPreferences = UserPreferences()
        
        // MARK: - Storage Provider
    @AppStorage("storageType") var storageType: StorageType = .swiftData
    private var swiftDataStorageProvider: SwiftDataStorageProvider? = nil
        
        var storageProvider: StorageProvider {
            switch storageType {
            case .swiftData:
                return swiftDataStorageProvider ?? SwiftDataStorageProvider(schema: Schema([]))
                //case .json:
                //   return JSONStorageProvider.shared
            }
        }

    init() {
        // Descubrir y registrar plugins automáticamente
        let discoveredPlugins = PluginDiscovery.discoverPlugins()
        for pluginType in discoveredPlugins {
            PluginRegistry.shared.register(pluginType)
        }
        
        print("📝 Plugins registrados en AppConfig: \(PluginRegistry.shared.count)")
        
        // Crear instancias de los plugins
        self.plugins = PluginRegistry.shared.createPluginInstances(config: self)
        // Now plugins are available
        var schemas: [any PersistentModel.Type] = []
        schemas.append(contentsOf: PluginRegistry.shared.getEnabledModels(from: plugins))
        let schema = Schema(schemas)
        print("📦 Schemas registrados: \(schemas)")
        print("🔌 Plugins activos: \(plugins.filter { $0.isEnabled }.count)/\(plugins.count)")
        self.swiftDataStorageProvider = SwiftDataStorageProvider(schema: schema)
        setupHabitDataObservingPlugins()
    }
    
   // private let modelContainer: ModelContainer
    
    //init(modelContainer: ModelContainer) {
     //   self.modelContainer = modelContainer
       // setupPlugins()
    //}
    
    private func setupHabitDataObservingPlugins() {
        let registry = HabitDataObserverManager.shared
        registry.register(HabitGoalPlugin(config: self))
        registry.register(StreakPlugin(config: self))
        print("✅ Plugins registrados correctamente")
    }
    
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
