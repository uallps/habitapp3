import Foundation

enum Frequency: Hashable {
    case daily
    case monthly
    case weekly
    case annual

    // Optional: an emoji representation
    var emoji: String {
        switch self {
        case .daily: return "🔁🌞"
        case .weekly: return "🌞📅🌙"
        case .monthly: return "📅"
        case .annual: return "🌱🌳"
        }
    }
}
