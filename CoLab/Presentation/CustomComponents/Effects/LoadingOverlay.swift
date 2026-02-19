//
//  LoadingOverlay.swift
//  CoLab
//
//  Created by User on 18.02.2026.
//

import UIKit

// Эффект загрузки для всего экрана
final class LoadingOverlay: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let firstAlpha: CGFloat = 0.05
        static let secondAlpha: CGFloat = 0.1
        static let thirdAlpha: CGFloat = 0.05
        
        static let startX: CGFloat = 0
        static let endX: CGFloat = 1
        static let standardY: CGFloat = 0.5
        static let locations: [NSNumber] = [0, 0.5, 1]
        
        static let animationFromValue = [-1, -0.5, 0]
        static let animationToValue = [1, 1.5, 2]
        static let animationDuration: CGFloat = 1.4
        
        static let stringKeyPath = "locations"
        
    }

    private let gradientLayer = CAGradientLayer()

    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true

        // цвета переливания
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(Constants.firstAlpha).cgColor,
            UIColor.white.withAlphaComponent(Constants.secondAlpha).cgColor,
            UIColor.white.withAlphaComponent(Constants.thirdAlpha).cgColor
        ]

        gradientLayer.startPoint = CGPoint(x: Constants.startX, y: Constants.standardY)
        gradientLayer.endPoint = CGPoint(x: Constants.endX, y: Constants.standardY)
        gradientLayer.locations = Constants.locations

        layer.addSublayer(gradientLayer)
    }
    
    // MARK: Use-cases

    func show(over parent: UIView) {
        parent.addSubview(self)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            topAnchor.constraint(equalTo: parent.topAnchor),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])

        startAnimation()
    }

    func hide() {
        stopAnimation()
        removeFromSuperview()
    }

    private func startAnimation() {
        let animation = CABasicAnimation(keyPath: Constants.stringKeyPath)
        animation.fromValue = Constants.animationFromValue
        animation.toValue = Constants.animationToValue
        animation.duration = Constants.animationDuration
        animation.repeatCount = .infinity

        gradientLayer.add(animation, forKey: nil)
    }

    private func stopAnimation() {
        gradientLayer.removeAllAnimations()
    }
    
    // MARK: Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
