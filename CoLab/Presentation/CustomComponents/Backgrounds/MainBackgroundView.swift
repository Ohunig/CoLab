//
//  MainBackgroundView.swift
//  CoLab
//
//  Created by User on 21.01.2026.
//

import UIKit

// Основной фон экранов приложения
final class MainBackgroundView: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let glowViewsSize: CGFloat = 783
        
        static let topGlowViewLeading: CGFloat = 28
        static let topGlowViewTop: CGFloat = -485
        
        static let bottomGlowViewLeading: CGFloat = -549
        static let bottomGlowViewTop: CGFloat = 478
    }
    
    private var color: UIColor
    
    private var gradColor: UIColor
    
    var bgColor: UIColor {
        get { color }
        set {
            color = newValue
            configureUI()
        }
    }
    
    var gradientColor: UIColor {
        get { gradColor }
        set {
            gradColor = newValue
            configureUI()
        }
    }
    
    // MARK: Lifecycle
    
    init(
        backgroundColor: UIColor = .black,
        gradientColor: UIColor = .black
    ) {
        self.color = backgroundColor
        self.gradColor = gradientColor
        super.init(frame: .zero)
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        self.backgroundColor = color
        configureGlowViews()
    }
    
    private func configureGlowViews() {
        let topGlowView = GlowView()
        let bottomGlowView = GlowView()
        topGlowView.centerColor = gradColor
        bottomGlowView.centerColor = gradColor
        topGlowView.outerColor = color
        bottomGlowView.outerColor = color
        topGlowView.translatesAutoresizingMaskIntoConstraints = false
        bottomGlowView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(topGlowView)
        self.addSubview(bottomGlowView)
        
        NSLayoutConstraint.activate(
            [
                topGlowView.widthAnchor.constraint(equalToConstant: Constants.glowViewsSize),
                topGlowView.heightAnchor.constraint(equalToConstant: Constants.glowViewsSize),
                topGlowView.leadingAnchor.constraint(
                    equalTo: self.leadingAnchor,
                    constant: Constants.topGlowViewLeading
                ),
                topGlowView.topAnchor.constraint(
                    equalTo: self.topAnchor,
                    constant: Constants.topGlowViewTop
                ),
                
                bottomGlowView.widthAnchor.constraint(equalToConstant: Constants.glowViewsSize),
                bottomGlowView.heightAnchor.constraint(equalToConstant: Constants.glowViewsSize),
                bottomGlowView.leadingAnchor.constraint(
                    equalTo: self.leadingAnchor,
                    constant: Constants.bottomGlowViewLeading
                ),
                bottomGlowView.topAnchor.constraint(
                    equalTo: self.topAnchor,
                    constant: Constants.bottomGlowViewTop
                )
            ]
        )
    }
}
