import SwiftUI
import Combine
import SwiftData

// ObservableObject es un protocolo que garantiza que esta clase tiene datos que, cuando cambian, desencadenan actualizaciones en la interfaz de usuario.
// Concepto similar a los estados mutables en Jetpack Compose.
class AppConfig: ObservableObject  {

    // @AppStorage conecta automáticamente una propiedad con UserDefaults.

    // UserDefaults en Swift (y en desarrollo iOS/macOS) es un sistema simple de almacenamiento clave-valor que permite a tu app
    // persistir pequeñas cantidades de datos entre ejecuciones.
    // No debe considerarse una base de datos relacional como las bases de datos SQLite en apps de Android. Solo almacena datos pequeños
    // directamente en disco, sin relaciones entre ellos.
    // Básicamente, cualquier propiedad marcada con @AppStorage se lee o escribe según las circunstancias adecuadas.
    
    // MARK: - Plugin Management
    private var plugins: [FeaturePlugin] = []
    
    // MARK: - Storage Provider
    
    private lazy var swiftDataProvider: SwiftDataStorageProvider = {
        // Obtener modelos base
        var schemas: [any PersistentModel.Type] = [Habit.self]
        
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
            return swiftDataProvider
        //case .json:
         //   return JSONStorageProvider.shared
        }
    }
    
    @AppStorage("storageType")
    var storageType: StorageType = .swiftData
    
    @AppStorage("showCategories")
    static var showCategories: Bool = true
    @AppStorage("showDueDates")
    static var  showDueDates : Bool = true
    @AppStorage("showPriorities")
    static var showPriorities : Bool = true
    @AppStorage("enableReminders")
    static var enableReminders: Bool = true}

enum StorageType: String, CaseIterable, Identifiable {
    case swiftData = "SwiftDataStorage"
    //case json = "JSONStorage"

    var id: String { self.rawValue }
}
