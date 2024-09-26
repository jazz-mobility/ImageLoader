import SwiftUI
import ImageLoader

struct ContentView: View {
    @StateObject private var viewModel = ImageLoaderListViewModel()

    var body: some View {
        List(viewModel.imageURLs, id: \.self) { urlString in
            ImageRowView(imageURL: urlString)
                .frame(height: 200)
                .padding(.vertical, 5)
        }
        .onAppear {
            viewModel.loadImageURLs()
        }
    }
}

@MainActor
class ImageLoaderListViewModel: ObservableObject {
    @Published var imageURLs: [String] = []

    // Function to load multiple image URLs (you can add real image URLs here)
    func loadImageURLs() {
        self.imageURLs = (100...200).map { "https://picsum.photos/\($0)" }
    }
}


struct ImageRowView: View {
    let imageURL: String
    @StateObject private var viewModel = ImageLoaderViewModel()

    var body: some View {
        VStack {
            if let uiImage = viewModel.image {
#if canImport(UIKit)
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
#elseif canImport(AppKit)
                Image(nsImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
#endif
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            viewModel.loadImage(from: imageURL)
        }
    }
}

@MainActor
class ImageLoaderViewModel: ObservableObject {
    @Published var image: PlatformImage? = nil
    private let imageLoader: ImageLoader

    init(imageLoader: ImageLoader = CachedImageLoader.default) {
        self.imageLoader = imageLoader
    }

    // Function to load image from URL
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        Task {
            do {
                if let loadedImage = try await imageLoader.loadImage(from: url) {
                    self.image = loadedImage
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
