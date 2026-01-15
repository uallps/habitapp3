import SwiftUI
import SwiftData
import Combine


class AppConfig: ObservableObject {
    @MainActor static let shared = AppConfig()
    
    // MARK: - Plugin Management
    private var plugins: [FeaturePlugin] = []
    var userPreferences: UserPreferences = UserPreferences()
    
    // MARK: - Storage Provider
    @AppStorage("storageType") var storageType: StorageType = .swiftData
    private var swiftDataStorageProvider: SwiftDataStorageProvider? = nil
    
    var storageProvider: StorageProvider {
        switch storageType {
        case .swiftData:
            guard let provider = swiftDataStorageProvider else {
                fatalError("storageProvider requested before initialization")
            }
            return provider
        }
    }
    
    @MainActor 
    private init() {
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
        //observadores DESPUÉS de que el storageProvider esté listo
        setupHabitDataObservingPlugins()
    }
    
   
    
    private func setupHabitDataObservingPlugins() {
        let registry = HabitDataObserverManager.shared
        registry.register(HabitGoalPlugin(config: self))
        print("✅ Plugins registrados correctamente")
    }
    
   
    

    enum StorageType: String, CaseIterable, Identifiable {
        case swiftData = "SwiftDataStorage"
        //case json = "JSONStorage"
        
        var id: String { self.rawValue }
    }
}
