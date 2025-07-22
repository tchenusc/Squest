import Foundation
import UIKit

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var url: URL?
    private static var cache = NSCache<NSURL, UIImage>()

    func preload(from url: URL?) {
        guard let url = url else {
            DispatchQueue.main.async { self.image = nil }
            return
        }
        self.url = url
        if let cached = ImageLoader.cache.object(forKey: url as NSURL) {
            DispatchQueue.main.async { self.image = cached }
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                ImageLoader.cache.setObject(uiImage, forKey: url as NSURL)
                DispatchQueue.main.async {
                    if self.url == url { self.image = uiImage }
                }
            }
        }.resume()
    }
} 