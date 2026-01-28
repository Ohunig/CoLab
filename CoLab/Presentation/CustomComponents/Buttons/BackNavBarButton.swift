//
//  BackNavBarButton.swift
//  CoLab
//
//  Created by User on 27.01.2026.
//

import UIKit

final class BackNavBarButton: UIButton {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let animateDuration: CGFloat = 0.06
        static let standardAlpha: CGFloat = 1
        static let tappedAlpha: CGFloat = 0.5
        
        static let standardImageSize: CGFloat = 24
        static let standardCornerRadius: CGFloat = 22
        static let standardBorderWidth: CGFloat = 1
        static let standardButtonSize: CGFloat = 44
        
        static let backgroundColorStandardAlpha: CGFloat = 0.5
    }
    
    private let image: UIImageView
    
    var baseColor: UIColor? {
        get {
            self.backgroundColor
        }
        // устанавливается цвет с изменённой альфой так как не заявлется что это именно backgroundColor
        set {
            self.backgroundColor = newValue?.withAlphaComponent(
                Constants.backgroundColorStandardAlpha
            )
            self.layer.borderColor = newValue?.cgColor
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
    
    init(image: UIImage) {
        self.image = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        super.init(frame: .zero)
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        layer.cornerRadius = Constants.standardCornerRadius
        layer.borderWidth = Constants.standardBorderWidth
        clipsToBounds = true
        
        configureImage()
    }
    
    private func configureImage() {
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        addSubview(image)
        
        NSLayoutConstraint.activate(
            [
                image.heightAnchor.constraint(
                    equalToConstant: Constants.standardImageSize
                ),
                image.widthAnchor.constraint(equalTo: heightAnchor),
                image.centerXAnchor.constraint(equalTo: centerXAnchor),
                image.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        )
    }
    
    // MARK: Tint color did change
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        image.tintColor = tintColor
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: Constants.standardButtonSize,
            height: Constants.standardButtonSize
        )
    }
}
