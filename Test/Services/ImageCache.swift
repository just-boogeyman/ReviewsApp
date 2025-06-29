import UIKit

/// Класс позволяющий кэшировать изображения
final class ImageCache {
	static let shared = ImageCache()
	
	private let cache = NSCache<NSString, UIImage>()

	private init() {}

	func image(forKey key: String) -> UIImage? {
		return cache.object(forKey: key as NSString)
	}

	func setImage(_ image: UIImage, forKey key: String) {
		cache.setObject(image, forKey: key as NSString)
	}
}
