import SwiftUI

/// Nivel alcanzado según la puntuación acumulada de logros.
enum AchievementLevel {
    case none
    case beginner
    case intermediate
    case advanced
    
    init(score: Int) {
        switch score {
        case 0:
            self = .none
        case 1..<120:
            self = .beginner
        case 120..<300:
            self = .intermediate
        default:
            self = .advanced
        }
    }
    
    var title: String {
        switch self {
        case .none: return "Sin nivel"
        case .beginner: return "Principiante"
        case .intermediate: return "Intermedio"
        case .advanced: return "Avanzado"
        }
    }
    
    var systemImage: String {
        switch self {
        case .none: return "circle"
        case .beginner: return "leaf.fill"
        case .intermediate: return "flame.fill"
        case .advanced: return "star.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .none: return .gray
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .purple
        }
    }
}
