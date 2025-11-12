//
//  Priority.swift
//  HabitApp
//
//  Created by Aula03 on 15/10/25.
//

import Foundation

enum Priority: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
        
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
    
    // Optional: an emoji representation
    var emoji: String {
        switch self {
        case .high: return "🔴"
        case .medium: return "🟠"
        case .low: return "🟢"
        }
    }
}
