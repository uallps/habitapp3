import SwiftUI
import Combine

class EmojiSearchModel: ObservableObject {
    @Published var searchText: String
    @Published var filteredEmojis: [Emojis]
    
    private var allEmojis: [Emoji]
    
    init(allEmojis: [Emoji]) {
        self.allEmojis = allEMojis
        self.filteredEmojis = []
    }
    
    func updateFilter() {
        let query = searchText.lowercased()
        if query.isEmpty {
            filteredEmojis = allEmojis
        } else {
            filteredEmojis = allEmojis.filter { emoji in
                allEmojis[emoji]?.name.contains(query) ?? false
            }
        }
    }

    func searchEmojis(with emojiDesc: String) {
        searchText = emojiDesc
        updateFilter()
    }
}