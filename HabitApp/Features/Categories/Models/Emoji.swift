import Foundation
import SwiftData

@Model
class Emoji: Comparable, Equatable, Hashable, Encodable, Decodable {
    var emoji: String
    var name: String
    
    @Attribute(.unique)
    var id: UUID

    enum CodingKeys: String, CodingKey {
        case emoji, name, id
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
    }
    
    required init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        emoji = try container.decode(String.self, forKey: .emoji)
        name = try container.decode(String.self, forKey: .name)
        id = try container.decode(UUID.self, forKey: .id)
    }
    
    init(emoji: String, name: String, id: UUID = UUID()) {
        self.emoji = emoji
        self.name = name
        self.id = id
    }
    
    // MARK: - Comparable
    static func < (lhs: Emoji, rhs: Emoji) -> Bool {
        lhs.name < rhs.name
    }
    
    // MARK: - Equatable
    static func == (lhs: Emoji, rhs: Emoji) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


