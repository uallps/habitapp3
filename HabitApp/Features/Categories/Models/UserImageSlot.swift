import SwiftUI
import SwiftData

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

@Model
class UserImageSlot: Encodable, Decodable {
    
    @Attribute
    var id: UUID = UUID()
    
    enum CodingKeys: String, CodingKey {
        case imageData, emojis
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imageData, forKey: .imageData)
        try container.encode(emojis, forKey: .emojis)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageData = try container.decode(Data.self, forKey: .imageData)
        emojis = try container.decode([Emoji].self, forKey: .emojis)
    }
    
    // Ni NSImage ni UIImage son PersistentModel, por lo que hay que almacenar la imagen en una base de datos de otra manera (con Data).
    var image: PlatformImage? {
        get { imageData.flatMap { PlatformImage(data: $0) } }
        set {
#if os(iOS)
            imageData = newValue?.pngData()
#else
            imageData = newValue?.tiffRepresentation
#endif
        }
    }
    var imageData: Data?
    
    init(image: PlatformImage?) {
#if os(iOS)
        self.imageData = image?.pngData()
#else
        self.imageData = image?.tiffRepresentation
#endif
    }
    
    var emojis: [Emoji]?
    
    init(emojis: [Emoji]) {
        self.emojis = emojis
    }
}
