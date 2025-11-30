import SwiftUI
import PhotosUI

struct UserImagesPickerView: View {
    @StateObject var viewModel = UserImagesViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Imagen")) {
                    HStack {
                        ForEach(viewModel.slots.indices, id: \.self) { index in
                            Button {
                                viewModel.activeSlotIndex = index
                            } label: {
                                if let image = viewModel.slots[index].image {
                                    #if os(iOS)
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                    #elseif os(macOS)
                                    Image(nsImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(8)
                                    #endif
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                        .overlay(Text("+").font(.title))
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Pick Images")) {
                    #if os(iOS)
                    PhotosPicker(
                        selection: Binding(
                            get: { nil },
                            set: { item in
                                guard let item = item else { return }
                                Task { await viewModel.loadImage(from: item) }
                            }
                        ),
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("Select Image from Library")
                    }
                    #elseif os(macOS)
                    Button("Select Image from Library") {
                        let panel = NSOpenPanel()
                        panel.allowedFileTypes = ["png", "jpg", "jpeg"]
                        panel.allowsMultipleSelection = false
                        if panel.runModal() == .OK, let url = panel.url,
                           let nsImage = NSImage(contentsOf: url) {
                            viewModel.assign(image: nsImage)
                            viewModel.pickedImages.append(nsImage)
                        }
                    }
                    #endif
                }
                
                Section {
                    Button("Save Category") {
                        // Save using viewModel.slots
                    }
                }
            }
            .navigationTitle("New Category")
        }
    }
}
