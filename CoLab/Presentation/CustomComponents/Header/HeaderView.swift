//
//  UserChatsHeaderView.swift
//  CoLab
//
//  Created by User on 22.03.2026.
//

import UIKit

final class HeaderView: UIView {
    
    private struct Constants {
        static let preferredHeight: CGFloat = 44
        static let logoAspectRatio: CGFloat = 176 / 44
        static let convergedGapRatio: CGFloat = 10 / 48
        static let horizontalConvergenceFactor: CGFloat = 0.4
        static let minimumScale: CGFloat = 0.5
        static let avatarTransitionDuration: CGFloat = 0.25
    }
    
    static let preferredHeight: CGFloat = Constants.preferredHeight
    
    private let logoView = CoLabLogo()
    private let avatarView = CircleImage(UIImage())
    private let avatarOverlay = LoadingOverlay()
    
    private var compressionProgressValue: CGFloat = 0
    
    var baseColor: UIColor? {
        didSet {
            logoView.baseColor = baseColor
            avatarView.borderColor = baseColor
        }
    }
    
    var textColor: UIColor? {
        didSet {
            logoView.textColor = textColor
        }
    }
    
    var avatarImage: UIImage? {
        didSet {
            avatarView.image = avatarImage
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCompression()
    }
    
    func setCompressionProgress(_ progress: CGFloat) {
        compressionProgressValue = progress
        updateCompression()
    }
    
    func setAvatarImage(_ image: UIImage?, animated: Bool) {
        let updateAvatar = {
            self.avatarImage = image
        }
        avatarOverlay.hide()
        
        guard animated, avatarView.window != nil else {
            updateAvatar()
            return
        }
        
        UIView.transition(
            with: avatarView,
            duration: Constants.avatarTransitionDuration,
            options: .transitionCrossDissolve
        ) {
            updateAvatar()
        }
    }
    
    func showAvatarLoading() {
        guard avatarOverlay.superview == nil else { return }
        avatarOverlay.show(over: avatarView)
    }
    
    func hideAvatarLoading() {
        avatarOverlay.hide()
    }
    
    private func configureUI() {
        backgroundColor = .clear
        
        logoView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(logoView)
        addSubview(avatarView)
        
        NSLayoutConstraint.activate([
            logoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            logoView.topAnchor.constraint(equalTo: topAnchor),
            logoView.bottomAnchor.constraint(equalTo: bottomAnchor),
            logoView.widthAnchor.constraint(
                equalTo: logoView.heightAnchor,
                multiplier: Constants.logoAspectRatio
            ),
            
            avatarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarView.topAnchor.constraint(equalTo: topAnchor),
            avatarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor)
        ])
    }
    
    private func updateCompression() {
        let clampedProgress = max(0, min(compressionProgressValue, 1))
        let clampedScale = 1 - (1 - Constants.minimumScale) * clampedProgress
        
        logoView.transform = .identity
        avatarView.transform = .identity
        
        let logoBaseFrame = logoView.frame
        let avatarBaseFrame = avatarView.frame
        guard logoBaseFrame.isEmpty == false, avatarBaseFrame.isEmpty == false else {
            return
        }
        
        let logoTargetWidth = logoBaseFrame.width * clampedScale
        let logoTargetHeight = logoBaseFrame.height * clampedScale
        let avatarTargetWidth = avatarBaseFrame.width * clampedScale
        let avatarTargetHeight = avatarBaseFrame.height * clampedScale
        let convergedGap = bounds.height * Constants.convergedGapRatio
        let groupWidth = logoTargetWidth + avatarTargetWidth + convergedGap
        let groupStartX = (bounds.width - groupWidth) / 2
        
        let logoTargetFrame = CGRect(
            x: groupStartX,
            y: 0,
            width: logoTargetWidth,
            height: logoTargetHeight
        )
        let avatarTargetFrame = CGRect(
            x: groupStartX + logoTargetWidth + convergedGap,
            y: 0,
            width: avatarTargetWidth,
            height: avatarTargetHeight
        )
        
        let logoTranslateX = (logoTargetFrame.midX - logoBaseFrame.midX)
            * clampedProgress
            * Constants.horizontalConvergenceFactor
        let avatarTranslateX = (avatarTargetFrame.midX - avatarBaseFrame.midX)
            * clampedProgress
            * Constants.horizontalConvergenceFactor
        let logoTranslateY = (logoTargetFrame.midY - logoBaseFrame.midY)
            * clampedProgress
        let avatarTranslateY = (avatarTargetFrame.midY - avatarBaseFrame.midY)
            * clampedProgress
        
        logoView.transform = CGAffineTransform(
            translationX: logoTranslateX,
            y: logoTranslateY
        ).scaledBy(
            x: clampedScale,
            y: clampedScale
        )
        
        avatarView.transform = CGAffineTransform(
            translationX: avatarTranslateX,
            y: avatarTranslateY
        ).scaledBy(
            x: clampedScale,
            y: clampedScale
        )
        avatarView.refreshCircularMask()
    }
}
