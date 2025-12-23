import Foundation
import SwiftData

enum Frequency: String, Hashable, Codable, CaseIterable {
    case daily
    case monthly
    case weekly
    case annual
    case mixed // Para categorías. Una categoría puede forzar a todos sus hábitos tener una frecuencia en particular. Si tiene mixed, admite de cualquier tipo.

    // Optional: an emoji representation
    var emoji: String {
        switch self {
        case .daily: return "🔁🌞"
        case .weekly: return "🌞📅🌙"
        case .monthly: return "📅"
        case .annual: return "🌱🌳"
        case .mixed: return "🎨"
        }
    }
}
