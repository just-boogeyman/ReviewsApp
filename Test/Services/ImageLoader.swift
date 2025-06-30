//
//  ImageLoader.swift
//  Test
//
//  Created by Ярослав Кочкин on 30.06.2025.
//

import UIKit

/// Протокол загрузчика изображений
protocol ImageLoading {
	func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void)
}

/// Сервис загрузки изображений с кэшированием
final class ImageLoader {

	/// Хранение загруженных изображений.
	private let cache = NSCache<NSString, UIImage>()
	
}

extension ImageLoader: ImageLoading {
	
	/// Загрузчик изображений.
	///
	/// - Parameters:
	/// - urlString: Строка с URL, по которому необходимо загрузить изображение.
	/// - completion: Замыкание, которое будет вызвано по завершении загрузки. Возвращает `UIImage` при успехе или `nil` при ошибке.

	func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {

		guard let url = URL(string: urlString) else {
			completion(nil)
			return
		}

		if let cachedImage = cache.object(forKey: urlString as NSString) {
			completion(cachedImage)
			return
		}

		let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
			guard
				let data = data,
				let image = UIImage(data: data),
				error == nil
			else {
				DispatchQueue.main.async {
					completion(nil)
				}
				return
			}

			self?.cache.setObject(image, forKey: urlString as NSString)

			DispatchQueue.main.async {
				completion(image)
			}
		}

		task.resume()
	}
	
}

