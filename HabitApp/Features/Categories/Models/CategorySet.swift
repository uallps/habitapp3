import SwiftUI
import SwiftData

@Model
class CategorySet: Identifiable, Hashable {
    
    @Attribute(.unique) var id: UUID
    
    var name: String    // Almacena una representación hasheable del color (nombre del asset).
    
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
        default: return Color(colorAssetName)
        }
    }
    
    var icon: UserImageSlot
    var priority: Priority
    var frequency: Frequency
    
    
    init(
        id: UUID = UUID(),
        name: String,
        colorAssetName: String = "black",
        icon: UserImageSlot,
        priority: Priority,
        frequency: Frequency,
    ) {
        self.id = id
        self.name = name
        self.colorAssetName = colorAssetName
        self.icon = icon
        self.priority = priority
        self.frequency = frequency
    }
}
