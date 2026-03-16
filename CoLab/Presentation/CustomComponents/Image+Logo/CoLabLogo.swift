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
        static let imageInset: CGFloat = 7
        
        static let standardBorderWidth: CGFloat = 1
        static let standardWrapperSize: CGFloat = 44
        
        static let gap: CGFloat = 10
        
        static let numberOfLines = 1
        static let fontSize: CGFloat = 24
        static let labelText = "Co:lab"
        
        static let backgroundColorStandardAlpha: CGFloat = 0.5
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
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .medium)
        addSubview(label)
    }
    
    // MARK: Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        wrapper.frame = CGRect(
            x: 0,
            y: 0,
            width: Constants.standardWrapperSize,
            height: Constants.standardWrapperSize
        )
        wrapper.layer.cornerRadius = Constants.standardWrapperSize / 2
        
        image.frame = CGRect(
            x: Constants.imageInset,
            y: Constants.imageInset,
            width: Constants.standardWrapperSize - Constants.imageInset * 2,
            height: Constants.standardWrapperSize - Constants.imageInset * 2
        )
        
        let labelSize = label.intrinsicContentSize
        label.frame = CGRect(
            x: wrapper.frame.width + Constants.gap,
            y: (Constants.standardWrapperSize - labelSize.height) / 2,
            width: labelSize.width,
            height: labelSize.height
        )
    }
}
