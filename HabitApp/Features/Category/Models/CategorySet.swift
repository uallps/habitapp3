import SwiftUI

struct CategorySet: Identifiable, Hashable {
    let id: UUID
    var name: String
    // Almacena una representación hasheable del color (nombre del asset).
    var colorAssetName: String
    var icon: Icon
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
        icon: Icon,
        priority: Priority,
        frequency: Frequency,
        progress: Progress
    ) {
        self.id = id
        self.name = name
        self.colorAssetName = colorAssetName
        self.icon = icon
        self.priority = priority
        self.frequency = frequency
    }
}
