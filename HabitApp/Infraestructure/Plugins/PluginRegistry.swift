//
//  PluginRegistry .swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

import SwiftUI
import SwiftData

struct PluginRegistry {
    static let shared = PluginRegistry()
    
    /// Instancias de plugins creadas
    private let pluginInstances: [FeaturePlugin] = []
    
    var dataObservers: [TaskDataObservingPlugin] = [
        ReminderPlugin()
        // Aquí puedes agregar más plugins de datos
    ]
    
    /// Obtiene todos los modelos de los plugins habilitados
    /// - Parameter plugins: Array de instancias de plugins
    /// - Returns: Array de tipos de modelos persistentes
    func getEnabledModels(from plugins: [FeaturePlugin]) -> [any PersistentModel.Type] {
        return plugins.flatMap { plugin in
            plugin.isEnabled ? plugin.models : []
        }
    }

}
