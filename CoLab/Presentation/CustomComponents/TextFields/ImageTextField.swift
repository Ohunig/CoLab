//
//  ImageTextField.swift
//  CoLab
//
//  Created by User on 26.01.2026.
//

import UIKit

final class ImageTextField: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let backgroundColorStandardAlpha: CGFloat = 0.5
        static let standardCornerRadius: CGFloat = 30
        static let standardCornerWidth: CGFloat = 1
        
        static let horisontalInset: CGFloat = 20
        static let verticalInset: CGFloat = 10
        
        static let imageHeight: CGFloat = 40
        
        static let standardFontSize: CGFloat = 24
        static let textFieldLeading: CGFloat = 20
    }
    
    private let image: UIImageView
    
    private let textField = UITextField()
    
    // MARK: Computed properties
    
    var placeholder: String? {
        get {
            textField.placeholder
        }
        set {
            textField.placeholder = newValue
            updatePlaceholderColor()
        }
    }
    
    var textColor: UIColor? {
        get {
            textField.textColor
        }
        set {
            textField.textColor = newValue
        }
    }
    
    var baseColor: UIColor? {
        get {
            self.backgroundColor
        }
        // устанавливается цвет с изменённой альфой так как не заявлется что это именно backgroundColor
        set {
            self.backgroundColor = newValue?.withAlphaComponent(Constants.backgroundColorStandardAlpha)
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    var text: String? {
        get {
            textField.text
        }
        set {
            textField.text = newValue
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
        self.layer.cornerRadius = Constants.standardCornerRadius
        self.layer.borderWidth = Constants.standardCornerWidth
        
        configureImage()
        configureTextField()
    }
    
    private func configureImage() {
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(image)
        
        NSLayoutConstraint.activate(
            [
                image.leadingAnchor.constraint(
                    equalTo: self.leadingAnchor,
                    constant: Constants.horisontalInset
                ),
                image.centerYAnchor.constraint(
                    equalTo: self.centerYAnchor
                ),
                image.heightAnchor.constraint(
                    equalToConstant: Constants.imageHeight
                ),
                image.widthAnchor.constraint(
                    equalTo: image.heightAnchor
                ),
                image.topAnchor.constraint(
                    greaterThanOrEqualTo: self.topAnchor
                ),
                image.bottomAnchor.constraint(
                    lessThanOrEqualTo: self.bottomAnchor
                )
            ]
        )
    }
    
    private func configureTextField() {
        textField.delegate = self
        textField.font = .systemFont(
            ofSize: Constants.standardFontSize,
            weight: .medium
        )
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textField)
        
        NSLayoutConstraint.activate(
            [
                textField.leadingAnchor.constraint(
                    equalTo: image.trailingAnchor,
                    constant: Constants.textFieldLeading
                ),
                textField.centerYAnchor.constraint(
                    equalTo: self.centerYAnchor
                ),
                textField.trailingAnchor.constraint(
                    equalTo: self.trailingAnchor,
                    constant: -Constants.horisontalInset
                )
            ]
        )
    }
    
    // MARK: Update
    
    private func updatePlaceholderColor() {
        guard let text = textField.placeholder else { return }
        textField.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: tintColor ?? .secondaryLabel]
        )
    }
    
    // MARK: Tint color did change
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        image.tintColor = tintColor
        textField.tintColor = tintColor
        updatePlaceholderColor()
    }
    
    // MARK: Target
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        textField.addTarget(target, action: action, for: controlEvents)
    }
}

// MARK: - Text field delegate extension

extension ImageTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
