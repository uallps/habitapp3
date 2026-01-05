import SwiftUI
import SwiftData
import Combine

final class AppConfig: ObservableObject {
    // 1. Propiedades ESTÁTICAS (Acceso global vía AppConfig.nombre)
    // Ponemos todas las preferencias aquí para que no den error en las vistas
    @AppStorage("showDueDates") static var showDueDates: Bool = true
    @AppStorage("showPriorities") static var showPriorities: Bool = true
    @AppStorage("enableReminders") static var enableReminders: Bool = true
    @AppStorage("enableStreaks") static var enableStreaks: Bool = true

    // 2. Definición del Esquema (Instancia)
    // Se usa internamente para inicializar la base de datos
    var schema: Schema {
        Schema([
            Habit.self,
            DailyNote.self,
            Goal.self,
            Milestone.self,
            Streak.self
        ])
    }

    // 3. El motor de almacenamiento (Instancia)
    lazy var storageProvider: StorageProvider = {
        return SwiftDataStorageProvider(schema: schema)
    }()
    
    init() {}
}
