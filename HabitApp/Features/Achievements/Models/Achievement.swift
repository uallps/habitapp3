import Foundation
import SwiftData

/// Logro simple
@Model
final class Achievement {
    @Attribute(.unique) var id: UUID
    var achievementId: String  // ID del logro en el catálogo
    var title: String
    var achievementDescription: String
    var iconName: String
    var unlockedAt: Date?  // Opcional, solo cuando se desbloquea
    var isUnlocked: Bool
    
    init(achievementId: String, title: String, description: String, iconName: String) {
        self.id = UUID()
        self.achievementId = achievementId
        self.title = title
        self.achievementDescription = description
        self.iconName = iconName
        self.unlockedAt = nil
        self.isUnlocked = false
    }
}
