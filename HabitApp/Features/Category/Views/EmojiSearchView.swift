import SwiftUI

struct EmojiSearchView: View {
    
    @StateObject private var loader: EmojiLoader = EmojiLoader()
    @StateObject private var model: EmojiSearchModel

    init() {
        let loader = EmojiLoader()
        _loader = StateObject(wrappedValue: loader)
        _model = StateObject(wrappedValue: EmojiSearchModel(allEmojis: loader.emojis))
    }
    
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
                        Text(emoji.emoji)
                            .font(.largeTitle)
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}
