import Foundation
import SwiftData

/// Plugin para habilitar/deshabilitar la funcionalidad de estadísticas
final class StatisticsPlugin: FeaturePlugin {
    
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    
    required init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableStatistics
        self.models = [] // No necesita modelos adicionales, usa los existentes
    }
}
