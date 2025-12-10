import SwiftUI
import PhotosUI
import Combine

@MainActor
class UserImagesViewModel: ObservableObject {
    @Published var image: PlatformImage? = nil
    @Published var pickedImages: [PlatformImage] = []

    func assign(image: PlatformImage) {
        self.image = image
    }
    
    func loadImage(from item: PhotosPickerItem) async {
        #if os(iOS)
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            pickedImages.append(uiImage)
            assign(image: uiImage)
        }
        #elseif os(macOS)
        if let uiImage = try? await item.loadTransferable(type: NSImage.self) {
            pickedImages.append(uiImage)
            assign(image: uiImage)
        }
        #endif
    }
    
}
