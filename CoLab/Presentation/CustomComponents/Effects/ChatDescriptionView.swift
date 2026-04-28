//
//  ChatDescriptionView.swift
//  CoLab
//
//  Created by User on 28.04.2026.
//

import UIKit

final class ChatDescriptionView: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let backgroundColorStandardAlpha: CGFloat = 0.5
        
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 1
        
        static let horisontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 12
        
        static let fontSize: CGFloat = 16
        static let numberOfLines = 0
    }
    
    private let label = UILabel()
    
    private var base: UIColor?
    private var labelColor: UIColor?
    private var labelText = String()
    
    // MARK: Computed properties
    
    var baseColor: UIColor? {
        get { base }
        set {
            base = newValue
            backgroundColor = newValue?.withAlphaComponent(
                Constants.backgroundColorStandardAlpha
            )
            layer.borderColor = newValue?.cgColor
        }
    }
    
    var textColor: UIColor? {
        get { labelColor }
        set {
            labelColor = newValue
            label.textColor = newValue
        }
    }
    
    var text: String {
        get { labelText }
        set {
            labelText = newValue
            label.text = newValue
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
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        clipsToBounds = true
        
        configureLabel()
        
        baseColor = .white
        textColor = .white
    }
    
    private func configureLabel() {
        label.font = .systemFont(
            ofSize: Constants.fontSize,
            weight: .regular
        )
        label.numberOfLines = Constants.numberOfLines
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Constants.verticalInset
            ),
            label.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.horisontalInset
            ),
            label.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.horisontalInset
            ),
            label.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Constants.verticalInset
            )
        ])
    }
}
