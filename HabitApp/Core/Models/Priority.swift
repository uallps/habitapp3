import Foundation

enum Priority: String, Hashable, Codable, CaseIterable {
    case low, medium, high
    
    // Optional: a color for SwiftUI
    var color: String {
        switch self {
        case .high:
            return "Red"
        case .medium:
            return "Orange"
        case .low:
            return "Green"
        }
    }
        
        var localized: String {
            switch self {
            case .low: return NSLocalizedString("priority_low", comment: "")
            case .medium: return NSLocalizedString("priority_medium", comment: "")
            case .high: return NSLocalizedString("priority_high", comment: "")
            }
        }
        
        // Optional: an emoji representation
        var emoji: String {
            switch self {
            case .high: return "🔴"
            case .medium: return "🟠"
            case .low: return "🟢"
            }
        }
    }

