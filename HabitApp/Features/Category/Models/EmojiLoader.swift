import SwiftUI
import Combine

class EmojiLoader: ObservableObject {
    @Published var emojis: [String] = []
    
    init() {
        loadEmojis()
    }
    
    private func loadEmojis() {
        DispatchQueue.global(qos: .userInitiated).async {
            var allEmojis: [String] = []
            
            // Unicode scalars from U+1F300 to U+1FAFF roughly covers all common emojis
            for scalarValue in 0x1F300...0x1FAFF {
                if let scalar = UnicodeScalar(scalarValue) {
                    let char = Character(scalar)
                    if char.isEmoji {
                        allEmojis.append(String(char))
                    }
                }
            }
            
            // Optional: sort or deduplicate
            allEmojis = Array(Set(allEmojis)).sorted()
            
            DispatchQueue.main.async {
                self.emojis = allEmojis
            }
        }
    }
}
