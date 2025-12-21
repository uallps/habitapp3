import Foundation
import SwiftData

enum Frequency: String, Hashable, Codable, CaseIterable {
    case daily
    case monthly
    case weekly
    case annual

    // Optional: an emoji representation
    var emoji: String {
        switch self {
        case .daily: return "Diaria 🔁🌞"
        case .weekly: return "Semanal 🌞📅🌙"
        case .monthly: return "Mensual 📅"
        case .annual: return "Anual 🌱🌳"
        }
    }
}
