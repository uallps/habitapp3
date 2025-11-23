import Foundation

struct Emoji: Identifiable, Hashable, Comparable {
    let id: String
    let emoji: String
    let name: String
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

extension Emoji {
    static func < (lhs: Emoji, rhs: Emoji) -> Bool {
        lhs.name < rhs.name
    }
}
