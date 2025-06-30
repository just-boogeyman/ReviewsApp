final class ReviewsScreenFactory {

    /// Создаёт контроллер списка отзывов, проставляя нужные зависимости.
    func makeReviewsController() -> ReviewsViewController {
        let reviewsProvider = ReviewsProvider()
		let imageLoader = ImageLoader()
        let viewModel = ReviewsViewModel(
			reviewsProvider: reviewsProvider,
			imageLoader: imageLoader
		)
        let controller = ReviewsViewController(viewModel: viewModel)
        return controller
    }

}
