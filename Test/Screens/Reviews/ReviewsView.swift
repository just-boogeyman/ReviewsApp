import UIKit

final class ReviewsView: UIView {

	var actionRefresh: (() -> Void)?
    let tableView = UITableView()
	private let customIndicator = CustomActivityIndicatorView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
    }
	
	func stopIndicator() {
		customIndicator.stopAnimating()
		customIndicator.isHidden = true
		tableView.isHidden = false
		tableView.reloadData()
	}
	
	func stopRefresh() {
		if tableView.refreshControl != nil {
			tableView.refreshControl?.endRefreshing()
		}
		tableView.reloadData()
	}

}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
		setupActivityIndicator()
		setupRefreshControl()
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
		tableView.register(ReviewsCountRatingCell.self, forCellReuseIdentifier: ReviewsCountCellConfig.reuseId)
		tableView.isHidden = true
    }
	
	func setupRefreshControl() {
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.tintColor = .systemPurple
		let attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.black,
			.font: UIFont.systemFont(ofSize: 14)
		]
		let attributedTitle = NSAttributedString(
			string: ConstansApp.Placeholder.update,
			attributes: attributes
		)
		tableView.refreshControl?.attributedTitle = attributedTitle
		tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
	}
	
	@objc func handleRefresh() {
		actionRefresh?()
	}
	
	private func setupActivityIndicator() {
		 addSubview(customIndicator)
		 customIndicator.translatesAutoresizingMaskIntoConstraints = false
		 NSLayoutConstraint.activate([
			 customIndicator.widthAnchor.constraint(equalToConstant: 40),
			 customIndicator.heightAnchor.constraint(equalToConstant: 40),
			 customIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
			 customIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
		 ])
	}

}
