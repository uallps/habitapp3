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
            if let url = Bundle.main.url(forResource: "emoji", withExtension: "txt"),
               let contents = try? String(contentsOf: url, encoding: .utf8) {
                fileLines = contents.components(separatedBy: .newlines)
            } else {
                fileLines = []
            }

            // Unicode scalars from U+1F300 to U+1FAFF roughly covers all common emojis
            for line in fileLines {
                
                let substrings = line.split(separator: ";")
                let emojiId : String
                let emoji : String
                let emojiDesc : String
                
                if(substrings.count >= 4 )  {
                    emojiId = String(substrings[0])
                    emoji = String(substrings[2])
                    emojiDesc = String(substrings[3])
                    allEmojis.append(Emoji(id: emojiId, emoji: emoji, name: emojiDesc))                }
            
                }
            
            
            DispatchQueue.main.async {
                self.emojis = allEmojis
            }
        }
    }
}
