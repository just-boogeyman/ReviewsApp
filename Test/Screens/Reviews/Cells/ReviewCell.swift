import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
	var maxLines = 3 {
		didSet {
			layout.invalidateCache()
		}
	}
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
	/// Имя пользователя.
	let userText: NSAttributedString
	/// Картинка рейтинга.
	let ratingImage: UIImage
	/// URL строки
	let avatarUrl: String
	/// Фотографии отзыва
	let reviewImages: [String]
	/// Сервис загрузки картинок.
	let imageLoader: ImageLoading

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
		cell.userTextLabel.attributedText = userText
		cell.ratingImage.image = ratingImage
		
		cell.loaderAvatar(from: avatarUrl, loader: imageLoader)
		cell.loadImages(from: reviewImages, loader: imageLoader)

        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

	private var imageLoader: ImageLoading?
    fileprivate var config: Config?
	
	/// Контейнер для фото.
	fileprivate var reviewPhotoViews: [UIImageView] = []

	fileprivate let ratingImage = UIImageView()
	fileprivate let avatarImage = UIImageView()
	fileprivate let userTextLabel = UILabel()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
		avatarImage.frame = layout.avatarImageFrame
		userTextLabel.frame = layout.userLableFrame
		ratingImage.frame = layout.ratingImageFrame
		for (index, frame) in config?.layout.photoFrames.enumerated() ?? [].enumerated() {
			if index < reviewPhotoViews.count {
				reviewPhotoViews[index].frame = frame
			}
		}
    }
	
	func configure(with config: ReviewCellConfig, imageLoader: ImageLoading) {
		self.imageLoader = imageLoader
	}
}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
		setupRatingImage()
		setupAvatarImage()
		setupUserLable()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
    }
	
	func setupRatingImage() {
		contentView.addSubview(ratingImage)
	}
	
	func setupAvatarImage() {
		contentView.addSubview(avatarImage)
		avatarImage.clipsToBounds = true
		avatarImage.layer.cornerRadius = Layout.avatarCornerRadius
		avatarImage.contentMode = .scaleAspectFill
		avatarImage.image = ConstansApp.Placeholder.avatar
	}
	
	func setupUserLable() {
		contentView.addSubview(userTextLabel)
	}

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
		showMoreButton.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)
    }

	@objc func showMoreTapped() {
		guard let config = config else { return }
		config.onTapShowMore(config.id)
	}
	
	func loadImages(from urls: [String], loader: ImageLoading) {
		
		reviewPhotoViews.forEach { $0.removeFromSuperview() }
		reviewPhotoViews.removeAll()
		
		for url in urls {
			let imageView = UIImageView()
			imageView.contentMode = .scaleAspectFill
			imageView.clipsToBounds = true
			imageView.layer.cornerRadius = CGFloat(Layout.photoCornerRadius)
			contentView.addSubview(imageView)
			reviewPhotoViews.append(imageView)
			
			loader.loadImage(from: url) { image in
				guard let image else { return }
				imageView.image = image
			}
		}
		
	}
	
	func loaderAvatar(from url: String, loader: ImageLoading) {
		loader.loadImage(from: url) { [weak self] image in
			guard let self else { return }
			
			if let image {
				self.avatarImage.image = image
			} else {
				return
			}
		}
	}

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
	
	/// свойство отвечающее за кэш "Height"
	private var cachedHeight: CGFloat?

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
	fileprivate static let ratingImageSize = CGSize(width: 60, height: 12)

    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

	private(set) var ratingImageFrame = CGRect.zero
	private(set) var avatarImageFrame = CGRect.zero
	private(set) var userLableFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
	private(set) var photoFrames: [CGRect] = []


    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
		if let cachedHeight = cachedHeight {
				return cachedHeight
			}
		
		avatarImageFrame = CGRect(
			origin: CGPoint(x: insets.left, y: insets.top),
			size: Self.avatarSize
		)
		
		let textStartX = avatarImageFrame.maxX + avatarToUsernameSpacing
		let availableWidth = maxWidth - textStartX - insets.right
		
		userLableFrame = CGRect(
			origin: CGPoint(x: textStartX, y: insets.top),
			size: config.userText.boundingRect(width: availableWidth).size
		)
		
		var maxY = userLableFrame.maxY + usernameToRatingSpacing
		
		ratingImageFrame = CGRect(
			origin: CGPoint(x: textStartX, y: maxY),
			size: Self.ratingImageSize
		)
		
		maxY = ratingImageFrame.maxY + ratingToPhotosSpacing
		
		photoFrames = []
		if !config.reviewImages.isEmpty {
			for (index, _) in config.reviewImages.prefix(5).enumerated() {
				let x = textStartX + CGFloat(index) * (Self.photoSize.width + photosSpacing)
				let y = maxY
				photoFrames.append(CGRect(origin: CGPoint(x: x, y: y), size: Self.photoSize))
			}
			maxY += Self.photoSize.height + photosToTextSpacing
		} else {
			// Если фото нет — просто отступ от рейтинга к тексту
			maxY = ratingImageFrame.maxY + ratingToTextSpacing
		}
		var showShowMoreButton = false

        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: availableWidth).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: textStartX, y: maxY),
                size: config.reviewText.boundingRect(width: availableWidth, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }

        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: textStartX, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        createdLabelFrame = CGRect(
            origin: CGPoint(x: textStartX, y: maxY),
            size: config.created.boundingRect(width: availableWidth).size
        )
		
		let totalHeight = createdLabelFrame.maxY + insets.bottom
		cachedHeight = totalHeight
		return totalHeight
    }
	
	func invalidateCache() {
		cachedHeight = nil
	}

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
