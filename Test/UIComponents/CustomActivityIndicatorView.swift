import UIKit

/// Кастомный индикатор загрузки
final class CustomActivityIndicatorView: UIView {

	private let shapeLayer = CAShapeLayer()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupShapeLayer()
		startAnimating()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupShapeLayer() {
		let radius: CGFloat = 20
		let lineWidth: CGFloat = 4
		let center = CGPoint(x: bounds.midX, y: bounds.midY)
		let circularPath = UIBezierPath(
			arcCenter: center,
			radius: radius,
			startAngle: -(.pi / 2),
			endAngle: 3 * .pi / 2,
			clockwise: true
		)

		shapeLayer.path = circularPath.cgPath
		shapeLayer.strokeColor = UIColor.systemBlue.cgColor
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.lineWidth = lineWidth
		shapeLayer.lineCap = .round
		shapeLayer.strokeStart = 0
		shapeLayer.strokeEnd = 0.25
		layer.addSublayer(shapeLayer)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		shapeLayer.frame = bounds
		shapeLayer.removeAllAnimations()
		setupShapeLayer()
		startAnimating()
	}

	/// Запускает анимацию вращения и рисования линии на CAShapeLayer.
	func startAnimating() {
		let headAnimation = CABasicAnimation(keyPath: "strokeStart")
		headAnimation.fromValue = 0
		headAnimation.toValue = 0.75
		headAnimation.duration = 1
		headAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

		let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
		tailAnimation.fromValue = 0.25
		tailAnimation.toValue = 1
		tailAnimation.duration = 1
		tailAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

		let rotation = CABasicAnimation(keyPath: "transform.rotation")
		rotation.byValue = 2 * Double.pi
		rotation.duration = 1
		rotation.repeatCount = .infinity

		let group = CAAnimationGroup()
		group.animations = [headAnimation, tailAnimation]
		group.duration = 1.5
		group.repeatCount = .infinity

		shapeLayer.add(group, forKey: "stroke")
		layer.add(rotation, forKey: "rotation")
	}

	/// Останавливает все текущие анимации.
	func stopAnimating() {
		layer.removeAllAnimations()
		shapeLayer.removeAllAnimations()
	}
}
