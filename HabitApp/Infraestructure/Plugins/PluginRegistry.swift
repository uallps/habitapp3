//
//  PluginRegistry .swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

import SwiftUI

struct PluginRegistry {
    static let shared = PluginRegistry()
    
    /// Instancias de plugins creadas
    private let pluginInstances: [FeaturePlugin] = []
    
    var dataObservers: [TaskDataObservingPlugin] = [
        ReminderPlugin()
        // Aquí puedes agregar más plugins de datos
    ]
    

}
