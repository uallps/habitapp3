import SwiftData
import Foundation

final class CategoryPlugin: FeaturePlugin {
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    let config: AppConfig
    
    init(config: AppConfig) {
        self.isEnabled = true
        self.models = [Category.self]
        self.config = config
    }
}
