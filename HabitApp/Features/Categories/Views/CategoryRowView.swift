import SwiftUI

struct CategoryRowView: View {
    
    let category: Category
    
    var body: some View {
        HStack {

            // El nombre de la categoría se almacena en minúsculas, pero se muestra con la primera letra en mayúsculas.
            Text(category.name.togglingFirstLetterCase)
            
            Circle()
                .fill(category.color)
                .frame(width: 26, height: 26)
                .overlay(
                    Circle().stroke(Color.black, lineWidth: 1)
                )
            
            if let image = category.icon.image {
                #if os(iOS)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 46, height: 46)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.black, lineWidth: 1)
                    )
                #elseif os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 46, height: 46)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.black, lineWidth: 1)
                    )
                #endif
            } else {
                Capsule()
                    .fill(Color.white)
                    .frame(width: 50, height: 40)
                    .overlay(
                        HStack(spacing: 0) {
                            ForEach(category.icon.emojis ?? [], id: \.self) { emoji in
                                Text(emoji.emoji)
                                    .font(.title2)
                            }
                        }
                    )
                    .overlay(
                        Capsule().stroke(Color.black, lineWidth: 1)
                    )
            }
            
            HStack() {
                #if os(macOS)
                Text(
                    "Prioridad: " + category.priority.emoji
                )
                #else
                Text(
                    "P: " + category.priority.emoji
                )
                #endif
            }
            
        }
    }
}
