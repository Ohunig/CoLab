//
//  ItemCell.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import UIKit

// Ячейка с текстом и картинкой в правой части
final class ItemCell: UIButton {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let standardImage = "chevron.right"
        
        static let animateDuration: CGFloat = 0.06
        static let standardAlpha: CGFloat = 1
        static let tappedAlpha: CGFloat = 0.5
        static let disabledAlpha: CGFloat = 0.3
        static let backgroundColorStandardAlpha: CGFloat = 0.5
        
        static let horisontalInset: CGFloat = 16
        
        static let standardImageSize: CGFloat = 30
        static let standardCornerRadius: CGFloat = 25
        static let standardBorderWidth: CGFloat = 1
        
        static let numberOfLines = 1
        static let fontSize: CGFloat = 20
    }
    
    private let image: UIImageView
    private let label = UILabel()
    
    private var base: UIColor?
    private var labelColor: UIColor?
    private var labelText = String()
    
    // MARK: Computed properties
    
    var baseColor: UIColor? {
        get { base }
        // устанавливается цвет с изменённой альфой так как не заявлется что это именно backgroundColor
        set {
            base = newValue
            self.backgroundColor = newValue?.withAlphaComponent(
                Constants.backgroundColorStandardAlpha
            )
            self.layer.borderColor = newValue?.cgColor
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
    
    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: Constants.animateDuration) {
                self.alpha = self.isEnabled ? Constants.standardAlpha : Constants.disabledAlpha
            }
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
    
    init(image: UIImage? = UIImage(systemName: Constants.standardImage)) {
        self.image = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
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
        configureText()
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
                image.widthAnchor.constraint(equalTo: image.heightAnchor),
                image.centerYAnchor.constraint(equalTo: centerYAnchor),
                image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horisontalInset)
            ]
        )
    }
    
    private func configureText() {
        label.numberOfLines = Constants.numberOfLines
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate(
            [
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horisontalInset),
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                label.trailingAnchor.constraint(equalTo: image.leadingAnchor)
            ]
        )
    }
    
    // MARK: Tint color did change
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        image.tintColor = tintColor
    }
}
