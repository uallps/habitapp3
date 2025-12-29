import Foundation
import SwiftData

@Model
class Emoji: Comparable, Equatable, Hashable, Encodable, Decodable {
    var emoji: String
    var name: String
    
    enum CodingKeys: String, CodingKey {
        case emoji, name
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(name, forKey: .name)
    }
    
    required init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        emoji = try container.decode(String.self, forKey: .emoji)
        name = try container.decode(String.self, forKey: .name)
    }
    
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


