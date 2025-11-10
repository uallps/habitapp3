import Foundation

enum Progress: String, CaseIterable, Codable, Identifiable {
    case done = "Done"
    case inProgress = "In progress"
    case notDone = "Not done"
        
    // Optional: an emoji representation
    var emoji: String {
        switch self {
        case .done: return "✅"
        case .inProgress: return "🔄"
        case .notDone: return "❌"
        }
    }
}
