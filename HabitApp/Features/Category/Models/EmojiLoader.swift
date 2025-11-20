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
            
            // Unicode scalars from U+1F300 to U+1FAFF roughly covers all common emojis
            for scalarValue in 0x1F300...0x1FAFF {
                if let scalar = UnicodeScalar(scalarValue) {
                    let char = Character(scalar)
                    if char.isEmoji {
                         let emojiStr = String(char)
                         let hex = String(format: "%04X", scalar.value)

                         let match = fileLines.first { line in
                            if line.contains(emojiStr) { return true }
                            if line.uppercased().contains("U+\(hex)") { return true }
                            if line.uppercased().contains("0X\(hex)") { return true }
                            if line.uppercased().contains(hex) { return true }
                            return false
                        }
                    }

                        let name: String
                        if let line = match {
                            // strip common tokens and the emoji itself to produce a readable description
                            var s = line
                            if let r = s.range(of: emojiStr) { s.removeSubrange(r) }
                            s = s.replacingOccurrences(of: "U+\(hex)", with: "", options: .caseInsensitive)
                            s = s.replacingOccurrences(of: "0x\(hex)", with: "", options: .caseInsensitive)
                            s = s.replacingOccurrences(of: hex, with: "", options: .caseInsensitive)
                            s = s.replacingOccurrences(of: ";", with: " ")
                            s = s.replacingOccurrences(of: "\t", with: " ")
                            s = s.replacingOccurrences(of: "-", with: " ")
                            s = s.trimmingCharacters(in: .whitespacesAndNewlines)
                            name = s.isEmpty ? (scalar.properties.name ?? "U+\(hex)") : s
                        } else {
                            name = scalar.properties.name ?? "U+\(hex)"
                        }

                        let id = "\(scalar.value)-\(hex)-\(emojiStr)"
                        allItems.append(Emoji(id: id, emoji: emojiStr, name: name, scalarValue: scalar.value))
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
