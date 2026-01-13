import SwiftUI
import PhotosUI
import Combine
import SwiftData

@MainActor
class UserImagesViewModel: ObservableObject {
    @Published var image: PlatformImage? = nil
    let storageProvider: StorageProvider
    var userImageSlot: UserImageSlot
    
    func assign(image: PlatformImage) {
        self.image = image
        Task {
           // try await storageProvider.upsertUserImageSlot(userImageSlot) DESECHADO
        }
    }
    
    init(storageProvider: StorageProvider, userImageSlot: UserImageSlot) {
        self.storageProvider = storageProvider
        self.userImageSlot = userImageSlot
    }
    
    func loadPickedImage() async {
        do {
            //self.image = try await storageProvider.loadPickedImage(userImageSlot).image
        } catch {
            print("Error loading image \(error)")
        }
    }
    
    func loadImage(from item: PhotosPickerItem) async {
        #if os(iOS)
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            assign(image: uiImage)
        }
        #elseif os(macOS)
        if let uiImage = try? await item.loadTransferable(type: NSImage.self) {
            assign(image: uiImage)
        }
        #endif
    }
    
}
