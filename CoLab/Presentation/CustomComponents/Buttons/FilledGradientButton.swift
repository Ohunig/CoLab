//
//  FilledGradientButton.swift
//  CoLab
//
//  Created by User on 22.01.2026.
//

import UIKit

// Заполненная кнопка с градиентом
final class FilledGradientButton: UIButton {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let standardCornerRadius: CGFloat = 25
        
        static let gradientStartX: CGFloat = 0
        static let gradientEndX: CGFloat = 1
        static let gradientY: CGFloat = 0.5
        
        static let animateDuration: CGFloat = 0.06
        static let standardAlpha: CGFloat = 1
        static let tappedAlpha: CGFloat = 0.5
        
        static let standardFontSize: CGFloat = 24
    }
    
    private let gradient = CAGradientLayer()
    
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
        layer.insertSublayer(gradient, at: 0)
        clipsToBounds = true
        
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .systemFont(
            ofSize: Constants.standardFontSize,
            weight: .medium
        )
        layer.cornerRadius = Constants.standardCornerRadius
        
        
        updateColors()
        configureGradient()
    }
    
    private func configureGradient() {
        gradient.startPoint = CGPoint(
            x: Constants.gradientStartX,
            y: Constants.gradientY
        )
        gradient.endPoint = CGPoint(
            x: Constants.gradientEndX,
            y: Constants.gradientY
        )
    }
    
    private func updateColors() {
        gradient.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    // MARK: Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
    }
}
