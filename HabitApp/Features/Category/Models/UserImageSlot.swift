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
class UserImageSlot: Icon {
    var image: PlatformImage?

    init(image: PlatformImage?, id: String) {
        self.image = image
        super.init(id: id)
    }
}
