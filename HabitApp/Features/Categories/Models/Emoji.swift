import Foundation
import SwiftData

@Model
class Emoji: Comparable, Equatable, Hashable {
    var emoji: String
    var name: String
    
    init(emoji: String, name: String, id: String) {
        self.emoji = emoji
        self.name = name
    }
    
    // MARK: - Comparable
    static func < (lhs: Emoji, rhs: Emoji) -> Bool {
        lhs.name < rhs.name
    }
    
    // MARK: - Equatable
    static func == (lhs: Emoji, rhs: Emoji) -> Bool {
        lhs.emoji == rhs.emoji
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(emoji)
    }
}


