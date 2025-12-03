import SwiftUI

struct CategorySet: Identifiable, Hashable {
    let id: UUID
    var name: String
    // Almacena una representación hasheable del color (nombre del asset).
    var colorAssetName: String
    var icon: UserImageSlot
    var priority: Priority
    var frequency: Frequency

    // Color calculado a partir del nombre del asset para que SwiftUI pueda seguir usando Color.
    var color: Color {
        Color(colorAssetName)
    }

    init(
        id: UUID = UUID(),
        name: String,
        colorAssetName: String = "AccentColor",
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
