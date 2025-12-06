import SwiftUI
import SwiftData

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

// UserImageSlot is now a subclass of CategoryIconBase
@Model
class UserImageSlot {
    
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
}
