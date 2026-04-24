//
//  TableContainerView.swift
//  CoLab
//
//  Created by User on 22.03.2026.
//

import UIKit

final class TableContainerView: UIView {
    
    private struct Constants {
        
        static let fatalError = "init(coder:) has not been implemented"
        
        static let cornerRadius: CGFloat = 34
        
        static let alphaComponents: [CGFloat] = [0.9, 0.5, 0.15]
        static let locations: [NSNumber] = [0, 0.05, 0.6, 1]
        static let startPoint = CGPoint(x: 0.5, y: 0)
        static let endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    private let panelView = UIView()
    private let glowLayer = CAGradientLayer()

    var fillColor: UIColor? {
        didSet {
            panelView.backgroundColor = fillColor
        }
    }
    
    var glowColor: UIColor? {
        didSet {
            updateGlowColors()
        }
    }
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        panelView.clipsToBounds = true
        addSubview(panelView)
        panelView.layer.addSublayer(glowLayer)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    // MARK: Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        panelView.frame = bounds
        panelView.layer.cornerRadius = Constants.cornerRadius
        panelView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        glowLayer.frame = panelView.bounds
    }
    
    // MARK: Update glow
    
    private func updateGlowColors() {
        let primary = glowColor?.withAlphaComponent(
            Constants.alphaComponents[0]
        ).cgColor ?? UIColor.clear.cgColor
        let secondary = glowColor?.withAlphaComponent(
            Constants.alphaComponents[1]
        ).cgColor ?? UIColor.clear.cgColor
        let tertiary = glowColor?.withAlphaComponent(
            Constants.alphaComponents[2]
        ).cgColor ?? UIColor.clear.cgColor
        glowLayer.colors = [primary, secondary, tertiary, UIColor.clear.cgColor]
        glowLayer.locations = Constants.locations
        glowLayer.startPoint = Constants.startPoint
        glowLayer.endPoint = Constants.endPoint
    }
}
