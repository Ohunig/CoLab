//
//  BorderGradientButton.swift
//  CoLab
//
//  Created by User on 23.01.2026.
//

import UIKit

// Кнопка с прозрачным центром и градиентной обводкой
final class BorderGradientButton: UIButton {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let standardCornerRadius: CGFloat = 30
        static let standardBorderWidth: CGFloat = 3
        
        static let gradientStartX: CGFloat = 0
        static let gradientEndX: CGFloat = 1
        static let gradientY: CGFloat = 0.5
        
        static let animateDuration: CGFloat = 0.06
        static let standardAlpha: CGFloat = 1
        static let tappedAlpha: CGFloat = 0.5
        
        static let standardFontSize: CGFloat = 24
    }
    
    private let gradientLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()

    var borderWidth: CGFloat = Constants.standardBorderWidth {
        didSet {
            setNeedsLayout()
        }
    }
    
    var startColor: UIColor = .clear {
        didSet {
            updateColors()
        }
    }
    
    var endColor: UIColor = .clear {
        didSet {
            updateColors()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            // Определяем изменение при нажатии
            UIView.animate(withDuration: Constants.animateDuration) {
                self.alpha = self.isHighlighted ? Constants.tappedAlpha : Constants.standardAlpha
            }
        }
    }
    
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    // MARK: Configure UI

    private func configureUI() {
        // Настраиваем заголовок
        titleLabel?.font = .systemFont(
            ofSize: Constants.standardFontSize,
            weight: .medium
        )
        
        backgroundColor = .clear
        // слой градиента
        configureGradient()
        updateColors()
        layer.addSublayer(gradientLayer)

        // shape layer используется как маска
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round

        // ограничиваем градиент маской
        gradientLayer.mask = shapeLayer
    }
    
    private func configureGradient() {
        gradientLayer.startPoint = CGPoint(
            x: Constants.gradientStartX,
            y: Constants.gradientY
        )
        gradientLayer.endPoint = CGPoint(
            x: Constants.gradientEndX,
            y: Constants.gradientY
        )
    }

    private func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    // MARK: Layout subview

    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        shapeLayer.frame = gradientLayer.bounds
        let inset = borderWidth / 2
        let path = UIBezierPath(
            roundedRect: shapeLayer.bounds.insetBy(
                dx: inset,
                dy: inset
            ),
            cornerRadius: Constants.standardCornerRadius
        )
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = borderWidth
    }
}
