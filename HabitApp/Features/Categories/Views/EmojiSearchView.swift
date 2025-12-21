import SwiftUI

struct EmojiSearchView: View {
    @Binding var selectedIcon: Emoji
    @StateObject private var loader = EmojiLoader()
    @StateObject private var model = EmojiSearchModel()

    // environment to dismiss the sheet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            if loader.emojis.isEmpty {
                ProgressView("Cargando emojis...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // make sure model has the latest emojis when loader finishes
                TextField("Buscar emoji...", text: $model.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 48))], spacing: 12) {
                        ForEach(model.filteredEmojis, id: \.self) { emoji in
                            Text(emoji.emoji)
                                .font(.system(size: 34))
                                .frame(width: 56, height: 56)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.2)))
                                .onTapGesture {
                                    selectedIcon = emoji
                                    dismiss()
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            // ensure model receives the loaded emoji list
            model.allEmojis = loader.emojis
        }
        .onReceive(loader.$emojis) { emojis in
            model.allEmojis = emojis
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}
