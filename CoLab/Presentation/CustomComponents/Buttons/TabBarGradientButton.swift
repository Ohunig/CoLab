//
//  TabBarGradientButton.swift
//  CoLab
//
//  Created by User on 07.03.2026.
//

import UIKit

final class TabBarGradientButton: UIButton {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let standardCornerRadius: CGFloat = 25
        
        static let gradientStartX: CGFloat = 0
        static let gradientEndX: CGFloat = 1
        static let gradientY: CGFloat = 0.5
        
        static let animateDuration: CGFloat = 0.06
        static let standardAlpha: CGFloat = 1
        static let tappedAlpha: CGFloat = 0.5
        static let disabledAlpha: CGFloat = 0.3
        
        static let standardFontSize: CGFloat = 24
    }
    
    private let gradient = CAGradientLayer()
    
    // Выбрана в данный момент кнопка в таб баре или нет
    var choosedNow: Bool = false {
        didSet {
            updateColors()
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
    
    // Цвет когда кнопка не выбрана в таб баре
    var notChoosedColor: UIColor = .clear {
        didSet {
            updateColors()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard isEnabled else { return }
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
        // Чтобы при установке картинки она растягивалась на всю кнопку
        imageView?.contentMode = .scaleAspectFit
        
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
        // Выбирает какие обновлённые цвета ставить в зависимости от того, выбрана кнопка или нет
        gradient.colors = choosedNow ? [startColor.cgColor, endColor.cgColor] : [notChoosedColor.cgColor, notChoosedColor.cgColor]
        // Строго заданы цвета надписей на кнопке, при внешнем изменении tintColor он не будет далее меняться в зависимости от того выбрана кнопка или нет
        tintColor = choosedNow ? .black : .white
    }
    
    // MARK: Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
    }
}
