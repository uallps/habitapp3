import Foundation
import SwiftData

#if WILD_CARD_FEATURE

final class WildcardPlugin: DataPlugin {
    var models: [any PersistentModel.Type]
    var isEnabled: Bool
    
    init(config: AppConfig) {
        self.isEnabled = config.userPreferences.enableWildcard
        self.models = [WildcardHistory.self]
    }
}

#endif
