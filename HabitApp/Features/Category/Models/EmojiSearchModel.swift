import SwiftUI
import Combine

class EmojiSearchModel: ObservableObject {
    @Published var searchText: String
    @Published var filteredEmojis: [Emoji]
    
    private var allEmojis: [Emoji]
    
    init(allEmojis: [Emoji]) {
        self.allEmojis = allEmojis
        self.filteredEmojis = []
        self.searchText = ""
    }
    
    func updateFilter() {
        let query = searchText.lowercased()
        if query.isEmpty {
            filteredEmojis = allEmojis
        } else {
            filteredEmojis = allEmojis.filter { emoji in
               emoji.name.contains(query)
            }
        }
    }

    func searchEmojis(with emojiDesc: String) {
        searchText = emojiDesc
        updateFilter()
    }
}
