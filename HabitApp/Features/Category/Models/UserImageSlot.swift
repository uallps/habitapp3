import SwiftUI

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

struct UserImageSlot : Hashable {
    let id = UUID()
    var image: PlatformImage?
}
