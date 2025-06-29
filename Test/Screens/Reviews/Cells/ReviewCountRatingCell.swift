import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewsCountCellConfig {
	
	/// Идентификатор для переиспользования ячейки.
	static let reuseId = String(describing: ReviewsCountCellConfig.self)
	
	/// Текст общего количества отзывов.
	let countText: NSAttributedString

}

// MARK: - TableCellConfig

extension ReviewsCountCellConfig: TableCellConfig {
	
	/// Метод обновления ячейки.
	/// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
	func update(cell: UITableViewCell) {
		guard let cell = cell as? ReviewsCountRatingCell else { return }
		cell.ratingCountLabel.attributedText = countText
	}

	/// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
	/// Вызывается из `heightForRowAt:` делегата таблицы.
	func height(with size: CGSize) -> CGFloat {
		let height = countText.boundingRect(width: size.width).height
		return height + Constants.insets.top + Constants.insets.bottom
	}
	
}

// MARK: - Cell

final class ReviewsCountRatingCell: UITableViewCell {
	
	fileprivate let ratingCountLabel = UILabel()
	
	// MARK: - Отступы

	/// Отступы от краёв ячейки до её содержимого.
	private let insets = Constants.insets

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupLabel()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

// MARK: - Layout

extension ReviewsCountRatingCell {
	
	private func setupLabel() {
		contentView.addSubview(ratingCountLabel)
		ratingCountLabel.numberOfLines = 0
		ratingCountLabel.textAlignment = .center
		ratingCountLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			ratingCountLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: insets.left
			),
			ratingCountLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -insets.right
			),
			ratingCountLabel.topAnchor.constraint(
				equalTo: contentView.topAnchor,
				constant: insets.top
			),
			ratingCountLabel.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -insets.bottom
			)
		])
	}
	
}

// MARK: - Constants

private enum Constants {
	static let insets = UIEdgeInsets(top: 9, left: 12, bottom: 9, right: 12)
}
