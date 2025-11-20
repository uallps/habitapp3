struct EmojiSearchView: View {

    @StateObject private var loader = EmojiLoader()

    private var allEmojis: [Emoji] {
        var keywords: [Emoji] = [:]

        for emoji in loader.emojis {
            keywords[emoji] = 
        }
        return keywords
    }

    @StateObject var model = EmojiSearchModel(allEmojis: allEmojis)
    
    var body: some View {
        VStack {
            TextField("Search emoji...", text: $model.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: model.searchText) { _ in
                    model.searchEmojis(with: model.searchText)
                }
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                    ForEach(model.filteredEmojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.largeTitle)
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}
