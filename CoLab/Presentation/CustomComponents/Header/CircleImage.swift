//
//  CircleImage.swift
//  CoLab
//
//  Created by User on 13.03.2026.
//

import UIKit

// Основной фон экранов приложения
final class CircleImage: UIView {
    
    private struct Constants {
        static let fatalError = "init(coder:) has not been implemented"
        
        static let borderWidth: CGFloat = 1
    }
    
    private var imageView: UIImageView
    
    private var border: UIColor?
    
    // MARK: Computed properties
    
    var image: UIImage? {
        get { imageView.image }
        set {
            imageView.image = newValue
        }
    }
    
    var borderColor: UIColor? {
        get { border }
        set {
            border = newValue
            layer.borderColor = newValue?.cgColor
        }
    }
    
    // MARK: Lifecycle
    
    init(_ image: UIImage?) {
        self.imageView = UIImageView(image: image)
        super.init(frame: .zero)
        
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(Constants.fatalError)
    }
    
    // MARK: Configure UI
    
    private func configureUI() {
        layer.borderWidth = Constants.borderWidth
        layer.masksToBounds = true
        clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        addSubview(imageView)
    }
    
    func refreshCircularMask() {
        let radius = bounds.width / 2
        layer.cornerRadius = radius
        imageView.layer.cornerRadius = radius
    }
    
    // MARK: Layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        refreshCircularMask()
    }
}
