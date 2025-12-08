import Foundation
import Combine

class CategoryListViewModel: ObservableObject {
    @Published var categories: [CategorySet] = [

    ]
    
    func addCategory(name: String, colorAssetName: String, icon: UserImageSlot, priority: Priority, frequency: Frequency, selectedEmojiOne, selectedEmojiTwo: String, selectedEmojiThree: String) {

        var emojis: [String] = []
        
        if !selectedEmojiOne.isEmpty {
            emojis.append(selectedEmojiOne)
        }
        if !selectedEmojiTwo.isEmpty {
            emojis.append(selectedEmojiTwo)
        }
        if !selectedEmojiThree.isEmpty {    
            emojis.append(selectedEmojiThree)
        }

        categories.append( CategorySet(
            id: UUID(),
            name: name,
            colorAssetName: colorAssetName,
            icon: icon,
            priority: priority,
            frequency: frequency,
            emojis: emojis
        ))
    }
}
