class EmojiSearchViewModel : ObservableObject {
    @Published private var loader = EmojiLoader()
    @Published var model = EmojiSearchModel()
}