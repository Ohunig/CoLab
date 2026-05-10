//
//  ChatVisibilitySwitchView.swift
//  CoLab
//
//  Created by User on 09.05.2026.
//

import UIKit

final class ChatVisibilitySwitchView: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        static let cornerRadius: CGFloat = 30
        static let borderWidth: CGFloat = 1
        static let backgroundAlpha: CGFloat = 0.5
        static let selectedAlpha: CGFloat = 0.9
        static let buttonFontSize: CGFloat = 18
        static let selectedInset: CGFloat = 6
        static let animationDuration: TimeInterval = 0.18
        static let publicTitle = "Публичный"
        static let privateTitle = "Непубличный"
    }
    
    private let selectedView = UIView()
    private let publicButton = UIButton(type: .system)
    private let privateButton = UIButton(type: .system)
    
    var onValueChanged: ((Bool) -> Void)?
    
    var isPublic = true {
        didSet {
            updateSelection(animated: true)
            onValueChanged?(isPublic)
        }
    }
    
    var baseColor: UIColor? {
        didSet {
            backgroundColor = baseColor?.withAlphaComponent(Constants.backgroundAlpha)
            layer.borderColor = baseColor?.cgColor
            selectedView.backgroundColor = baseColor?.withAlphaComponent(Constants.selectedAlpha)
        }
    }
    
    var textColor: UIColor? {
        didSet {
            updateButtonColors()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = Constants.cornerRadius
        selectedView.frame = selectedFrame()
        selectedView.layer.cornerRadius = max(
            0,
            (bounds.height - Constants.selectedInset * 2) / 2
        )
    }
    
    private func configureUI() {
        clipsToBounds = true
        layer.borderWidth = Constants.borderWidth
        
        configureSelectedView()
        configureButtons()
        updateSelection(animated: false)
    }
    
    private func configureSelectedView() {
        addSubview(selectedView)
    }
    
    private func configureButtons() {
        [publicButton, privateButton].forEach { button in
            button.titleLabel?.font = .systemFont(
                ofSize: Constants.buttonFontSize,
                weight: .medium
            )
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
        }
        
        publicButton.setTitle(Constants.publicTitle, for: .normal)
        privateButton.setTitle(Constants.privateTitle, for: .normal)
        
        publicButton.addAction(
            UIAction { [weak self] _ in
                self?.setPublic(true)
            },
            for: .touchUpInside
        )
        privateButton.addAction(
            UIAction { [weak self] _ in
                self?.setPublic(false)
            },
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            publicButton.topAnchor.constraint(equalTo: topAnchor),
            publicButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            publicButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            publicButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            
            privateButton.topAnchor.constraint(equalTo: topAnchor),
            privateButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            privateButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            privateButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func setPublic(_ isPublic: Bool) {
        guard self.isPublic != isPublic else { return }
        self.isPublic = isPublic
    }
    
    private func updateSelection(animated: Bool) {
        updateButtonColors()
        
        let changes = {
            self.selectedView.frame = self.selectedFrame()
        }
        
        guard animated, window != nil else {
            changes()
            return
        }
        
        UIView.animate(
            withDuration: Constants.animationDuration,
            delay: 0,
            options: [.curveEaseInOut, .allowUserInteraction],
            animations: changes
        )
    }
    
    private func selectedFrame() -> CGRect {
        guard bounds.width > 0, bounds.height > 0 else { return .zero }
        
        let height = max(0, bounds.height - Constants.selectedInset * 2)
        let width = max(0, (bounds.width - Constants.selectedInset * 2) / 2)
        let x = isPublic
            ? Constants.selectedInset
            : bounds.width - Constants.selectedInset - width
        
        return CGRect(
            x: x,
            y: Constants.selectedInset,
            width: width,
            height: height
        )
    }
    
    private func updateButtonColors() {
        let selectedColor = UIColor.black
        let normalColor = textColor ?? .white
        
        publicButton.setTitleColor(
            isPublic ? selectedColor : normalColor,
            for: .normal
        )
        privateButton.setTitleColor(
            isPublic ? normalColor : selectedColor,
            for: .normal
        )
    }
}
