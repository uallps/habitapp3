import SwiftUI
import SwiftData
import Combine


class AppConfig: ObservableObject {
    static let shared = AppConfig()
    
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
        
        // Agregar modelos manualmente si no están ya en el schema
        // (porque sus plugins fueron excluidos del target)
        if !schemas.contains(where: { $0 == Category.self }) {
            schemas.append(Category.self)
        }
        if !schemas.contains(where: { $0 == Addiction.self }) {
            schemas.append(Addiction.self)
        }
        
        let schema = Schema(schemas)
        print("📦 Schemas registrados: \(schemas)")
        print("🔌 Plugins activos: \(plugins.filter { $0.isEnabled }.count)/\(plugins.count)")
        self.swiftDataStorageProvider = SwiftDataStorageProvider(schema: schema)
        //observadores DESPUÉS de que el storageProvider esté listo
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
