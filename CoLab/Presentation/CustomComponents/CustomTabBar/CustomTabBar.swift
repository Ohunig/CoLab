//
//  CustomTabBar.swift
//  CoLab
//
//  Created by User on 07.03.2026.
//

import UIKit

final class CustomTabBar: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let standardBorderWidth: CGFloat = 1
        static let borderColorAlphaComponent: CGFloat = 1
        
        static let widthToButtonSizeMultiplier: CGFloat = 0.18
        static let topBottomWrapperInset: CGFloat = 10
        static let buttonsSpacing: CGFloat = 4
    }
    
    weak var delegate: CustomTabBarDelegate?

    private var buttons: [TabBarGradientButton] = []
    private let actionButton = FilledGradientButton()
    private let wrapper = UIView()
    
    var gradientColors: (UIColor, UIColor) = (.clear, .clear) {
        didSet {
            for button in buttons {
                button.startColor = gradientColors.0
                button.endColor = gradientColors.1
            }
            actionButton.startColor = gradientColors.0
            actionButton.endColor = gradientColors.1
        }
    }
    
    var standardButtonColor: UIColor = .clear {
        didSet {
            for button in buttons {
                button.notChoosedColor = standardButtonColor
            }
        }
    }
    
    var wrapperColor: UIColor = .clear {
        didSet {
            wrapper.backgroundColor = wrapperColor
            wrapper.layer.borderColor = wrapperColor.withAlphaComponent(
                Constants.borderColorAlphaComponent
            ).cgColor
        }
    }

    // MARK: Lifecycle
    
    init(
        itemImages: [UIImage?],
        actionImage: UIImage?
    ) {
        super.init(frame: .zero)
        for image in itemImages {
            let button = TabBarGradientButton()
            button.setImage(image, for: .normal)
            buttons.append(button)
        }
        actionButton.setImage(
            actionImage?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        
        configureActionButton()
        configureWrapper()
        configureButtons()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    // MARK: Configure view
    
    private func configureWrapper() {
        wrapper.layer.borderWidth = Constants.standardBorderWidth
        addSubview(wrapper)
    }
    
    private func configureButtons() {
        for (index, button) in buttons.enumerated() {
            let action = UIAction { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.customTabBar(self, didSelectIndex: index)
                selectButton(at: index)
            }
            button.addAction(action, for: .touchUpInside)
            addSubview(button)
        }
    }
    
    private func configureActionButton() {
        actionButton.tintColor = .black
        
        let action = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.customTabBarDidTapActionButton(self)
        }
        actionButton.addAction(action, for: .touchUpInside)
        addSubview(actionButton)
    }
    
    // MARK: UI updates
    
    func selectButton(at index: Int) {
        guard index >= 0 && index < buttons.count else { return }
        // Отжимаем все кнопки и помечаем нужную
        for button in buttons {
            button.choosedNow = false
        }
        buttons[index].choosedNow = true
    }
    
    // MARK: Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Если ширины экрана хватает, высчитывается размер кнопки в зависимости от высоты таб бара. Иначе высчитываем в зависимости от ширины
        let buttonSize = min(bounds.width * Constants.widthToButtonSizeMultiplier, frame.height - Constants.topBottomWrapperInset)
        
        var x: CGFloat = Constants.buttonsSpacing
        for button in buttons {
            button.frame = CGRect(
                x: x,
                y: (bounds.height - buttonSize) / 2,
                width: buttonSize,
                height: buttonSize
            )
            
            button.layer.cornerRadius = buttonSize / 2
            x += buttonSize + Constants.buttonsSpacing
        }
        
        wrapper.frame = CGRect(
            x: 0,
            y: (bounds.height - buttonSize - Constants.topBottomWrapperInset) / 2,
            width: x,
            height: buttonSize + Constants.topBottomWrapperInset
        )
        wrapper.layer.cornerRadius =  wrapper.frame.height / 2
        
        actionButton.frame = CGRect(
            x: bounds.width - buttonSize,
            y: (bounds.height - buttonSize) / 2,
            width: buttonSize,
            height: buttonSize
        )
        actionButton.layer.cornerRadius = buttonSize / 2
    }
}
