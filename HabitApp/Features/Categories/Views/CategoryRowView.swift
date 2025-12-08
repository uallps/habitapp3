import SwiftUI

struct CategoryRowView: View {
    
    let category: CategorySet
    
    var body: some View {
            VStack(alignment: .leading) {

                HStack(spacing: 12) {
                    if let iconImage = category.icon.image {
                        Image(uiImage: iconImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    } else if !category.emojis.isEmpty {

                        for iconEmoji in category.emojis {
                         Text(iconEmoji)
                            .font(.system(size: 36))
                        }

                    } else {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }

                Text(category.name)

                Text(category.colorAssetName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Prioridad: \(category.priority.rawValue.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Frecuencia: \(category.frequency.rawValue.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

            }
            
            Spacer()
        }
    }
