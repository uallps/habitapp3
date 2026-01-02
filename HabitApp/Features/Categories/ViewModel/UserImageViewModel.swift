import SwiftUI
import PhotosUI
import Combine
import SwiftData

@MainActor
class UserImagesViewModel: ObservableObject {
    @Published var image: PlatformImage? = nil
    private var modelContext: ModelContext?

    func assign(image: PlatformImage) {
        self.image = image
    }
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadPickedImage()
    }
    
    func loadPickedImage() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<UserImageSlot>(
            sortBy: [SortDescriptor(\.id, order: .forward)]
        )
        
        do {
            let fetchedImage = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading categories: \(error)")
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
