import SwiftUI
import SwiftData

@Model
class Category: Identifiable, Hashable, Encodable, Decodable, Comparable {
    
    @Attribute(.unique) var id: UUID
    var name: String    // Nombre de la categoría. Es único (Siempre se almacena en minúsculas y sin espacios, por lo que es irrelevante si el usuario usa mayúsculas o espacios)
    
    var colorAssetName: String
    
    var color: Color {
        switch colorAssetName.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "mint": return .mint
        case "teal": return .teal
        case "cyan": return .cyan
        case "blue": return .blue
        case "indigo": return .indigo
        case "purple": return .purple
        case "pink": return .pink
        case "brown": return .brown
        case "gray": return .gray
        default: return .red
        }
    }
    
    static func < (lhs: Category, rhs: Category) -> Bool {
        lhs.id < rhs.id
    }
    var icon: UserImageSlot
    var priority: Priority
    
    enum CodingKeys: String, CodingKey {
        case id, name, colorAssetName, icon, priority, subCategories
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(colorAssetName, forKey: .colorAssetName)
        try container.encode(icon, forKey: .icon)
        try container.encode(priority, forKey: .priority)
        try container.encode(subCategories, forKey: .subCategories)
    }
    
    required init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        colorAssetName = try container.decode(String.self, forKey: .colorAssetName)
        icon = try container.decode(UserImageSlot.self, forKey: .icon)
        priority = try container.decode(Priority.self, forKey: .priority)
    }

    var subCategories : [String: Category] = [:]
    var habits: [UUID: Habit] = [:]
    
    
    init(
        id: UUID = UUID(),
        name: String,
        colorAssetName: String = "black",
        icon: UserImageSlot,
        priority: Priority,
    ) {
        self.id = id
        self.name = name
        self.colorAssetName = colorAssetName
        self.icon = icon
        self.priority = priority
    }
}
