import Foundation

enum Frequency {
    case daily = "Daily"
    case monthly = "Monthly"
    case weekly = "Weekly"
    case annual = "Annual"
        
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
