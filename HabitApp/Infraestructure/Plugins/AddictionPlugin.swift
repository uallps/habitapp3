import SwiftData
import Foundation

final class AddictionPlugin: FeaturePlugin {
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    let config: AppConfig
    
    init(config: AppConfig) {
        self.isEnabled = true
        self.models = [Addiction.self]
        self.config = config
    }
}
