import Foundation

/// Clase responsable de descubrir automáticamente plugins que implementan FeaturePlugin
class PluginDiscovery {
    
    /// Descubre automáticamente todas las clases que implementan FeaturePlugin
    /// - Returns: Array de tipos de plugins encontrados
    static func discoverPlugins() -> [FeaturePlugin.Type] {
        var plugins: [FeaturePlugin.Type] = []
        
        // Obtener el bundle principal de la app
        guard let executableName = Bundle.main.executablePath?.components(separatedBy: "/").last else {
            return []
        }
        
        // Normalizar el nombre del ejecutable para matching de clases
        // (reemplazar espacios con underscores para coincidir con nombres de clases en runtime)
        let normalizedName = executableName.replacingOccurrences(of: " ", with: "_")
        let alternativeName = executableName.replacingOccurrences(of: " ", with: "")
        
        // Obtener todas las clases del runtime
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        
        var checkedCount = 0
        var skippedCount = 0
        var pluginCandidates = 0
        
        for i in 0 ..< actualClassCount {
            if let currentClass = allClasses[Int(i)] {
                let className = NSStringFromClass(currentClass)
                
                // OPTIMIZACIÓN 1: Filtrar solo clases de nuestro módulo/app
                // Aceptar: "HabitApp_", "HabitAppPremium", "HabitApp."
                let isFromOurBundle = className.hasPrefix(normalizedName) || 
                                     className.hasPrefix(alternativeName) ||
                                     className.hasPrefix("HabitApp")
                
                guard isFromOurBundle else {
                    skippedCount += 1
                    continue
                }
                
                checkedCount += 1
                
                // Verificar si la clase implementa FeaturePlugin
                if let pluginType = currentClass as? FeaturePlugin.Type {
                    pluginCandidates += 1
                    plugins.append(pluginType)
                }
            }
        }
        
        allClasses.deallocate()
        
        return plugins
    }
}
