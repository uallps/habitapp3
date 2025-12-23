import SwiftUI

struct CategoryRowView: View {
    
    let category: CategorySet
    
    var body: some View {
        HStack {
            Text(category.name)
            
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
            
            HStack() {
                #if os(macOs)
                Text(
                    "Frecuencia: " + category.frequency.emoji
                )
                #else
                Text(
                    "F: " + category.frequency.emoji
                )
                #endif
            }
        }
    }
}
