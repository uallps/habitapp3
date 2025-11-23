import SwiftUI
import Combine

// Carga emojis desde escalares Unicode y los mapea a sus descripciones

class EmojiLoader: ObservableObject {
    @Published var emojis: [Emoji] = []
    
    init() {
        loadEmojis()
    }
    
    private func loadEmojis() {
        DispatchQueue.global(qos: .userInitiated).async {
            var allEmojis: [Emoji] = []

            // Try to load emoji-test.txt from the app bundle
            let fileLines: [String]
            if let url = Bundle.main.url(forResource: "emoji-test", withExtension: "txt"),
               let contents = try? String(contentsOf: url, encoding: .utf8) {
                fileLines = contents.components(separatedBy: .newlines)
            } else {
                fileLines = []
            }
            
            print("Is fileLines empty?" , fileLines.isEmpty)
            
            // Unicode scalars from U+1F300 to U+1FAFF roughly covers all common emojis
            for scalarValue in 0x1F300...0x1FAFF {
                if let scalar = UnicodeScalar(scalarValue) {
                    let char = Character(scalar)
                    if char.isEmoji {
                        print("Char is emoji")
                         let emojiStr = String(char)
                         let hex = String(format: "%04X", scalar.value)
                        print("emojiStr: ", emojiStr)
                        print("hex: ", hex)

                         let match = fileLines.first { line in
                           print("line: ", line)
                            if line.contains(emojiStr) { return true }
                            if line.uppercased().contains("U+\(hex)") { return true }
                            if line.uppercased().contains("0X\(hex)") { return true }
                            if line.uppercased().contains(hex) { return true }
                            return false
                        }
                        
                        allEmojis.append(Emoji(id: hex, emoji: emojiStr, name: emojiStr, scalarValue: UInt32(scalarValue) ))
                        
                        
                    }


                }
            }
            
            // Optional: sort or deduplicate
            allEmojis = Array(Set(allEmojis)).sorted()
            
            DispatchQueue.main.async {
                print("Inside main async, self.emojis is Empty?", allEmojis.isEmpty)
                self.emojis = allEmojis
            }
        }
    }
}
