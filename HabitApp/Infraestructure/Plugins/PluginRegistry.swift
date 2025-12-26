//
//  PluginRegistry .swift
//  HabitApp
//
//  Created by Aula03 on 22/11/25.
//

struct PluginRegistry {
    static let shared = PluginRegistry()
    
    var dataObservers: [TaskDataObservingPlugin] = [
        ReminderPlugin()
        // Aquí puedes agregar más plugins de datos
    ]

}
