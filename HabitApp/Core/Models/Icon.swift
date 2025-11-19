import SwiftUI

enum Icon: Hashable {
    case emoji(String)        // Unicode emoji
    case custom(name: String) // Asset name
}
