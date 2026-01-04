import SwiftUI
import PhotosUI

struct UserImagesPickerView: View {
    @StateObject var viewModel: UserImagesViewModel

    #if os(iOS)
    @State private var pickedItem: PhotosPickerItem? = nil
    #endif

    var body: some View {
        NavigationStack {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        #if os(iOS)
        VStack(spacing: 16) {
            PhotosPicker(
                selection: $pickedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                imageButton
            }
            .onChange(of: pickedItem) { newItem in
                guard let item = newItem else { return }
                Task { await viewModel.loadImage(from: item) }
            }

            Spacer() // fill vertical space
        }
        .padding()
        #elseif os(macOS)
        Form {
            Section(header: Text("Imagen")) {
                Button {
                    let panel = NSOpenPanel()
                    panel.allowedFileTypes = ["png", "jpg", "jpeg"]
                    panel.allowsMultipleSelection = false
                    if panel.runModal() == .OK, let url = panel.url,
                       let nsImage = NSImage(contentsOf: url) {
                        viewModel.assign(image: nsImage)
                    }
                } label: {
                    imageButton
                }
            }
        }
        #endif
    }

    @ViewBuilder
    var imageButton: some View {
        if let image = viewModel.image {
            #if os(iOS)
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(12)
            #elseif os(macOS)
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .cornerRadius(12)
            #endif
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 120)
                .overlay(Text("+").font(.largeTitle))
        }
    }
}
