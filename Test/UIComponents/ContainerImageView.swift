import UIKit

final class ContainerImageView: UIView {
	
	private let imageView = UIImageView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(urlImage: String) {
		fetchImage(from: urlImage)
	}
	
}

// MARK: - Private

private extension ContainerImageView {
	
	func setup() {
		addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		setupLayout()
	}
	
	/// Метод загружает картинки по url и кэширует их
	func fetchImage(from urlString: String) {
		guard let url = URL(string: urlString) else { return }
		if let cachedImage = ImageCache.shared.image(forKey: urlString) {
			imageView.image = cachedImage
			return
		}
		DispatchQueue.global().async {
			guard let data = try? Data(contentsOf: url),
				  let image = UIImage(data: data) else {
				return
			}
			ImageCache.shared.setImage(image, forKey: urlString)

			DispatchQueue.main.async { [weak self] in
				self?.imageView.image = image
			}
		}
	}
	
}

// MARK: - Layout

private extension ContainerImageView {
	
	private func setupLayout() {
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
			imageView.topAnchor.constraint(equalTo: topAnchor),
			imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
}
