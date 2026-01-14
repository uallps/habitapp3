import Foundation
import SwiftData
import SwiftUI

/// Registro centralizado de plugins de características
class PluginRegistry {
    /// Instancia compartida del registro (Singleton)
    static let shared = PluginRegistry()
    
    //var dataObservers: [TaskDataObservingPlugin] = [
    //    ReminderPlugin()
    //    // Aquí puedes agregar más plugins de datos
    //]
    
    /// Array de tipos de plugins registrados
    private(set) var registeredPlugins: [FeaturePlugin.Type] = []
    
    /// Instancias de plugins creadas
    private var pluginInstances: [FeaturePlugin] = []
    
    /// Inicializador privado para el patrón Singleton
    private init() {}
    
    /// Registra un nuevo tipo de plugin
    /// - Parameter pluginType: Tipo del plugin a registrar
    func register(_ pluginType: FeaturePlugin.Type) {
        guard !registeredPlugins.contains(where: { $0 == pluginType }) else {
            return
        }
        
        registeredPlugins.append(pluginType)
        print(" Plugin registrado: \(pluginType)")
    }
    
    /// Crea instancias de todos los plugins registrados
    /// - Parameter config: Configuración de la aplicación
    /// - Returns: Array de instancias de plugins
    func createPluginInstances(config: AppConfig) -> [FeaturePlugin] {
        pluginInstances = registeredPlugins.map { pluginType in
            pluginType.init(config: config)
        }
        return pluginInstances
    }
    
    /// Obtiene todos los modelos de los plugins (siempre incluye todos los modelos para evitar errores de schema)
    /// - Parameter plugins: Array de instancias de plugins
    /// - Returns: Array de tipos de modelos persistentes
    func getEnabledModels(from plugins: [FeaturePlugin]) -> [any PersistentModel.Type] {
        // Siempre retorna todos los modelos, independientemente de si el plugin está habilitado
        // Esto evita errores de CoreData cuando se deshabilita/habilita funcionalidades
        return plugins.flatMap { plugin in
            plugin.models
        }
    }
    
    /// Limpia todos los plugins registrados (útil para testing)
    func clearAll() {
        registeredPlugins.removeAll()
        pluginInstances.removeAll()
    }
    
    /// Obtiene el número de plugins registrados
    var count: Int {
        return registeredPlugins.count
    }
    
    /// Obtiene todas las vistas de configuración de los plugins
    /// - Returns: Array de vistas de configuración proporcionadas por los plugins
    func getPluginSettingsViews() -> [AnyView] {
        return pluginInstances
            .compactMap { $0 as? any ViewPlugin }
            .map { AnyView($0.settingsView()) }
    }
}