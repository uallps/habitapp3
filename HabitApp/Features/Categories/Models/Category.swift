import SwiftUI
import SwiftData

@Model
class Category: Identifiable, Hashable {
    
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
    
    var icon: UserImageSlot
    var priority: Priority

    var subCategories = [String: Category] = [:]
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
