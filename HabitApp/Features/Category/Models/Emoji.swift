import Foundation

class Emoji: Icon, Comparable, Equatable {
    let emoji: String
    let name: String
    
    init(emoji: String, name: String, id: String) {
        self.emoji = emoji
        self.name = name
        super.init(id: id)
    }
    
    // MARK: - Comparable
    static func < (lhs: Emoji, rhs: Emoji) -> Bool {
        lhs.name < rhs.name
    }
    
    // MARK: - Equatable
    static func == (lhs: Emoji, rhs: Emoji) -> Bool {
        lhs.id == rhs.id
    }
}

extension Character {
    /// Returns true if the character is an emoji
    var isEmoji: Bool {
        // Some emojis are represented by a single scalar
        if self.unicodeScalars.count == 1 {
            return self.unicodeScalars.first?.properties.isEmojiPresentation ?? false
        }
        // Others are composed (like 👩‍💻) — treat them as emoji if any scalar is an emoji
        return self.unicodeScalars.contains { $0.properties.isEmoji }
    }
}
