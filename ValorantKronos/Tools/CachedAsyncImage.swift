import SwiftUI

/// A shared cache for storing images in memory.
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    /// Retrieves an image from the cache for a given key.
    /// - Parameter key: The key (typically the URL string) for the image.
    /// - Returns: The cached `UIImage`, or `nil` if it's not in the cache.
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    /// Stores an image in the cache.
    /// - Parameters:
    ///   - image: The `UIImage` to cache.
    ///   - key: The key (typically the URL string) to associate with the image.
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

/// A view that asynchronously loads and displays an image, with caching support.
struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    @ViewBuilder let content: (AsyncImagePhase) -> Content

    @State private var uiImage: UIImage?
    @State private var phase: AsyncImagePhase

    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.content = content
        _phase = State(initialValue: .empty)
    }

    var body: some View {
        content(phase)
            .task(id: url) {
                await loadImage()
            }
    }

    private func loadImage() async {
        guard let url = url else {
            phase = .empty
            return
        }

        // Check cache first
        if let cachedImage = ImageCache.shared.image(forKey: url.absoluteString) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }

        // If not in cache, fetch from network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                // Store in cache
                ImageCache.shared.setImage(image, forKey: url.absoluteString)
                // Update phase
                phase = .success(Image(uiImage: image))
            } else {
                phase = .failure(URLError(.cannotDecodeContentData))
            }
        } catch {
            phase = .failure(error)
        }
    }
}
