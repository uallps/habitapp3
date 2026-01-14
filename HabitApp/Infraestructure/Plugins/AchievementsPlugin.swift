import Foundation
import SwiftData

/// Plugin simple para habilitar/deshabilitar logros
final class AchievementsPlugin: FeaturePlugin {
    
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    
    required init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableAchievements
        self.models = [Achievement.self]
        
        print("AchievementsPlugin inicializado")
        print("   - Habilitado: \(isEnabled)")
        print("   - Modelos: \(models)")
    }
}
