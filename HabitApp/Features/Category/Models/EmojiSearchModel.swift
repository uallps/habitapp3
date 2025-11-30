
import Foundation
import Combine

class EmojiSearchModel: ObservableObject {
    @Published var searchText: String = "" {
        didSet { updateFilter() }
    }
    @Published private(set) var filteredEmojis: [Emoji] = []

    var allEmojis: [Emoji] {
        didSet { updateFilter() }
    }

    init(allEmojis: [Emoji] = []) {
        self.allEmojis = allEmojis
        self.filteredEmojis = allEmojis
    }

    private func updateFilter() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else {
            filteredEmojis = allEmojis
            return
        }

        filteredEmojis = allEmojis.filter { emoji in
            // match on name or the emoji character itself
            emoji.name.lowercased().contains(query) ||
            emoji.emoji.contains(query)
        }
    }

    // optional convenience
    func searchEmojis(with text: String) {
        searchText = text
    }
}
