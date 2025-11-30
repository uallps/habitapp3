import SwiftUI
import PhotosUI
import Combine

@MainActor
class UserImagesViewModel: ObservableObject {
    @Published var slots: [UserImageSlot] = [
        UserImageSlot(image: nil),
        UserImageSlot(image: nil),
        UserImageSlot(image: nil)
    ]
    
    @Published var pickedImages: [PlatformImage] = []
    @Published var activeSlotIndex: Int? = nil

    func assign(image: PlatformImage) {
        guard let index = activeSlotIndex, index < slots.count else { return }
        slots[index].image = image
    }
    
    func loadImage(from item: PhotosPickerItem) async {
        #if os(iOS)
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            pickedImages.append(uiImage)
            assign(image: uiImage)
        }
        #elseif os(macOS)
        if let data = try? await item.loadTransferable(type: Data.self),
           let nsImage = NSImage(data: data) {
            pickedImages.append(nsImage)
            assign(image: nsImage)
        }
        #endif
    }
}
