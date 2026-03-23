//
//  CoLabLogo.swift
//  CoLab
//
//  Created by User on 14.03.2026.
//

import UIKit

final class CoLabLogo: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let logoImage = UIImage(named: "CoLabScreenIcon")
        static let standardBorderWidth: CGFloat = 1
        static let numberOfLines = 1
        static let labelText = "Co:lab"
        
        static let backgroundColorStandardAlpha: CGFloat = 0.5
        static let referenceHeight: CGFloat = 44
        static let referenceWidth: CGFloat = 176
        static let imageInsetRatio: CGFloat = 7 / 44
        static let gapRatio: CGFloat = 10 / 44
        static let fontSizeRatio: CGFloat = 24 / 44
    }
    
    private let image = UIImageView(image: Constants.logoImage)
    private let wrapper = UIView()
    
    private let label = UILabel()
    
    private var base: UIColor?
    private var labelTextColor: UIColor?
    
    // MARK: Computed properties
    
    var baseColor: UIColor? {
        get { base }
        // устанавливается цвет с изменённой альфой так как не заявлется что это именно backgroundColor
        set {
            base = newValue
            wrapper.backgroundColor = newValue?.withAlphaComponent(
                Constants.backgroundColorStandardAlpha
            )
            wrapper.layer.borderColor = newValue?.cgColor
        }
    }
    
    var textColor: UIColor? {
        get { labelTextColor }
        set {
            labelTextColor = newValue
            label.textColor = newValue
        }
    }
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: Constants.referenceWidth,
            height: Constants.referenceHeight
        )
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        configureWrapper()
        configureImage()
        configureLabel()
    }
    
    private func configureWrapper() {
        wrapper.layer.borderWidth = Constants.standardBorderWidth
        wrapper.clipsToBounds = true
        addSubview(wrapper)
    }
    
    private func configureImage() {
        image.contentMode = .scaleAspectFit
        wrapper.addSubview(image)
    }
    
    private func configureLabel() {
        label.text = Constants.labelText
        label.numberOfLines = Constants.numberOfLines
        label.font = .systemFont(
            ofSize: Constants.referenceHeight * Constants.fontSizeRatio,
            weight: .medium
        )
        addSubview(label)
    }
    
    // MARK: Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let wrapperSize = min(bounds.height, bounds.width)
        let imageInset = wrapperSize * Constants.imageInsetRatio
        let gap = wrapperSize * Constants.gapRatio
        let fontSize = wrapperSize * Constants.fontSizeRatio
        
        wrapper.frame = CGRect(
            x: 0,
            y: 0,
            width: wrapperSize,
            height: wrapperSize
        )
        wrapper.layer.cornerRadius = wrapperSize / 2
        
        image.frame = CGRect(
            x: imageInset,
            y: imageInset,
            width: wrapperSize - imageInset * 2,
            height: wrapperSize - imageInset * 2
        )
        
        label.font = .systemFont(ofSize: fontSize, weight: .medium)
        let labelSize = label.intrinsicContentSize
        label.frame = CGRect(
            x: wrapper.frame.width + gap,
            y: (wrapperSize - labelSize.height) / 2,
            width: labelSize.width,
            height: labelSize.height
        )
    }
}
