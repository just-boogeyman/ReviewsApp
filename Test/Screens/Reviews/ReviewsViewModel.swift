import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {
	
	// MARK: - Types

	  /// Перечисление, описывающее типы ячеек в таблице отзывов:
	  /// `.review` — ячейка отзыва, `.count` — ячейка с общим числом отзывов.
	  private enum CellType {
		  case review(ReviewCellConfig)
		  case count(ReviewsCountCellConfig)
	  }
	
    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
	private let imageLoader: ImageLoading
    private let decoder: JSONDecoder
	
	/// Табличные элементы: отзывы и счётчик.
	private var cellItems: [CellType] {
		let reviewCells = state.items.compactMap { $0 as? ReviewCellConfig }.map(CellType.review)

		let countText = "\(reviewCells.count) отзывов".attributed(font: .created, color: .lightGray)
		let countCell = ReviewsCountCellConfig(countText: countText)

		return reviewCells + [.count(countCell)]
	}

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
		imageLoader: ImageLoading,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
		self.imageLoader = imageLoader
        self.decoder = decoder
    }
}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
		state.loadingState = state.offset == 0 ? .loading : .loaded
		onStateChange?(state)
        reviewsProvider.getReviews(offset: state.offset, completion: gotReviews)
    }

}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
		state.loadingState = .loaded
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map(makeReviewItem)
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
        } catch {
            state.shouldLoad = true
        }
        onStateChange?(state)
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }

	/// Возвращает конфигурацию ячейки для указанного индекса.
	/// Используется в `UITableViewDataSource` для построения ячеек.
	func item(at index: Int) -> TableCellConfig {
		switch cellItems[index] {
		case .review(let config): return config
		case .count(let config): return config
		}
	}
	
}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
		let userText = "\(review.first_name) \(review.last_name)".attributed(font: .username)
		let ratingImage = ratingRenderer.ratingImage(review.rating)
		let avatarUrl = review.avatar_url
		let imagesPhoto = review.reviewImages
		let item = ReviewItem(
            reviewText: reviewText,
            created: created,
			onTapShowMore: showMoreReview, 
			userText: userText,
			ratingImage: ratingImage,
			avatarUrl: avatarUrl,
			reviewImages: imagesPhoto,
			imageLoader: imageLoader
        )
        return item
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		cellItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let config = item(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let config = item(at: indexPath.row)
		return config.height(with: tableView.bounds.size)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}
