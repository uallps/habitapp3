class CategoryDetailWrapperViewViewModel: ObservableObject {
    @Published var allColors : [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown,
        .gray
    ]

    @Published var categorySet: CategorySet

    enum SelectionMode: String, CaseIterable, Identifiable {
          case emoji = "Emoji"
          case image = "Imagen"
          var id: String { rawValue }
    }

    enum ActiveSheet: Identifiable {
    case colorPicker
    case emoji(Int)

    var id: String {
        switch self {
        case .colorPicker: return "colorPicker"
        case .emoji(let id): return "emoji\(id)"
        }
    }
}
}